import os, strformat

type ApplicationArguments* = ref object
  pagesDir*: string
  postsDir*: string
  templatesDir*: string
  outputDir*: string
  templatesOutputDir*: string
  postsTemplate*: string
  partialsDir*: string

const pagesDirName = "pages"
const postsDirName = "posts"
const outputDirName = "dist"
const templatesDirName = "templates"

proc newApplicationArguments*(cwd: string): ApplicationArguments =
  new result

  if not existsDir(cwd):
    raise newException(ValueError, fmt"The path ({cwd}) is not a directory, or does not exist.")

  result.pagesDir = joinPath(cwd, pagesDirName)
  
  if not existsDir(result.pagesDir):
    raise newException(ValueError, fmt"Could not find a `pages` directory ({result.pagesDir}).")

  result.postsDir = joinPath(cwd, postsDirName)

  if not existsDir(result.postsDir):
    raise newException(ValueError, fmt"Could not find a `posts` directory ({result.postsDir}).")

  result.templatesDir = joinPath(cwd, templatesDirName)

  if not existsDir(result.templatesDir):
    raise newException(ValueError, fmt"Could not find a `templates` directory ({result.templatesDir}).")

  result.outputDir = joinPath(cwd, outputDirName)
  result.templatesOutputDir = joinPath(result.outputDir, postsDirName)
  result.postsTemplate = joinPath(result.templatesDir, "post.html")
  result.partialsDir = joinPath(result.templatesDir, "partials")
