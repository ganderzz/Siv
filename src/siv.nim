import os, asyncfile, asyncdispatch, strformat, markdown, strutils, moustachu, utils/markdownUtils,
    utils/applicationArguments

proc generateAllPostsData(postsDir: string): Future[seq[MdObject]] {.async.} =
  for kind, filePath in walkDir(postsDir):
    if kind == PathComponent.pcFile:
      let (_, fileName, extension) = splitFile(filePath)

      if extension != ".md":
        continue
      
      let file = openAsync(filePath)

      let fileContents = await file.readAll()
      result.add(newMarkdownObject(fileName, fileContents))
      file.close()

proc main(args: ApplicationArguments) {.async.} =
  discard existsOrCreateDir(args.outputDir)
  discard existsOrCreateDir(args.templatesOutputDir)

  let posts = await generateAllPostsData(args.postsDir)
  var postsMustacheContext: seq[Context] = @[]

  # Generate posts
  for post in posts:
    var mustacheContext = newContext(post.meta)

    mustacheContext["content"] = markdown(post.content, config = initGfmConfig())

    let html = renderFile(args.postsTemplate, mustacheContext, args.partialsDir)
    postsMustacheContext.add(mustacheContext)

    writeFile(joinPath(args.templatesOutputDir, fmt"{post.getFilename()}.html"), html)

  # Generate pages
  for kind, filePath in walkDir(args.pagesDir):
    if kind == PathComponent.pcFile:
      let (_, fileName, extension) = splitFile(filePath) 

      if extension != ".html":
        continue

      var mustacheContext = newContext({ "filename": fileName })
      mustacheContext["posts"] = postsMustacheContext 

      let html = renderFile(filePath, mustacheContext, args.partialsDir)

      writeFile(joinPath(args.outputDir, fmt"{filename}.html"), html)


when isMainModule:
  if paramCount() < 1:
    raise newException(ValueError, "Not enough arguments provided.")

  let args = newApplicationArguments(paramStr(1))

  waitFor main(args)

  echo "Siv :=: Complete!"
  
