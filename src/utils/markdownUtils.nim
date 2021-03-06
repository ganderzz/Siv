
import strutils, sequtils

type MdObject* = object
  meta*: seq[tuple[key: string, value: string]]
  originalFilename: string
  filename: string
  content*: string

method getOriginalFilename*(self: MdObject): string {.base.} =
  return self.originalFilename

method getFilename*(self: MdObject): string {.base.} =
  return self.filename

template formatMetaValue(input: string): string =
  strip(strip(input, chars = Whitespace), chars = {'"', '\''})

proc newMarkdownObject*(filename: string, markdown: TaintedString): MdObject =
  result.filename = filename.replace(" ", "-")
  result.originalFilename = filename
  result.meta.add((key: "url", value: "posts/" & result.filename & ".html"))

  if markdown.startsWith("---"):
    let line = markdown.split("---")

    if len(line) < 3:
      raise newException(ValueError, "Metadata in the incorrect format. Expecting `---` with closing `---`.")

    # Everything after the final `---`
    result.content = line[2]

    let splitMetadata = line[1].splitLines().filterIt(it != "")

    for item in splitMetadata:
      let splitItem = item.split(":", 1)

      if len(splitItem) != 2:
        raise newException(ValueError, "Could not parse metadata. Type malformed.")

      # @TODO: Currently doesn't support non-string types
      result.meta.add((key: splitItem[0], value: formatMetaValue(splitItem[1])))
