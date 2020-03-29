import os, strformat, markdown, strutils, moustachu, utils/markdownUtils,
    utils/applicationArguments

when isMainModule:
  if paramCount() < 1:
    raise newException(ValueError, "Not enough arguments provided.")

  let args = newApplicationArguments(paramStr(1))

  discard existsOrCreateDir(args.outputDir)

  for kind, postPath in walkDir(args.postsDir):
    if kind == PathComponent.pcFile:
      let (_, fileName, extension) = splitFile(postPath)

      if extension != ".md":
        continue

      let file = readFile(postPath)
      let data = createMarkdownObjectFromString(file)

      var c: Context = newContext(data.meta)

      c["content"] = markdown(data.content, config = initGfmConfig())

      let html = renderFile(joinPath(args.templatesDir, "post.html"), c,
          joinPath(args.templatesDir, "partials"))

      let escapedFileName = fileName.replace(" ", "-")

      writeFile(joinPath(args.outputDir, fmt"{escapedFileName}.html"), html)
