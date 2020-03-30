import os, asyncfile, asyncdispatch, times, sequtils, strformat, markdown, strutils, moustachu, utils/markdownUtils,
    utils/applicationArguments

proc generatePostContextsAsync(postsDir: string): Future[seq[tuple[filename: string, context: Context]]] {.async.} =
  for kind, filePath in walkDir(postsDir):
    if kind == PathComponent.pcFile:
      let (_, fileName, extension) = splitFile(filePath)

      if extension != ".md":
        continue
      
      let file = openAsync(filePath)

      let fileContents = await file.readAll()
      let post = newMarkdownObject(fileName, fileContents)
      var mustacheContext = newContext(post.meta)

      mustacheContext["content"] = markdown(post.content, config = initGfmConfig())

      result.add((filename: post.getFilename(), context: mustacheContext))
      file.close()

proc main(args: ApplicationArguments) {.async.} =
  # Create output directories if they don't exist
  discard existsOrCreateDir(args.outputDir)
  discard existsOrCreateDir(args.templatesOutputDir)

  let posts = await generatePostContextsAsync(args.postsDir)
  let postsContext = posts.mapIt(it.context)

  # Generate posts
  for post in posts:
    let html = renderFile(args.postsTemplate, post.context, args.partialsDir)

    writeFile(joinPath(args.templatesOutputDir, fmt"{post.filename}.html"), html)

  # Generate pages
  for kind, filePath in walkDir(args.pagesDir):
    if kind == PathComponent.pcFile:
      let (_, fileName, extension) = splitFile(filePath) 

      if extension != ".html":
        continue

      var mustacheContext = newContext({ "filename": fileName })
      mustacheContext["posts"] = postsContext

      let html = renderFile(filePath, mustacheContext, args.partialsDir)

      writeFile(joinPath(args.outputDir, fmt"{filename}.html"), html)


when isMainModule:
  if paramCount() < 1:
    raise newException(ValueError, "Not enough arguments provided.")

  let durationStart = cpuTime()
  let args = newApplicationArguments(paramStr(1))

  waitFor main(args)

  echo fmt"Siv completed in {cpuTime() - durationStart}s"
  
