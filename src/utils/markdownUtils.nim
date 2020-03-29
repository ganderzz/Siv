
import strutils, sequtils

type MdObject* = ref object
  meta*: seq[tuple[key: string, value: string]]
  filename: string
  content*: string

method getOriginalFileName*(self: MdObject): string {.base.} =
  return self.filename

proc formatMetaValue(input: string): string =
  return strip(strip(input, chars = Whitespace), chars = {'"', '\''})

proc newMarkdownObject*(filename: string, markdown: TaintedString): MdObject =
  new result

  result.filename = filename

  if markdown.startsWith("---"):
    let line = markdown.split("---")

    if len(line) < 3:
      raise newException(ValueError, "Metadata in the incorrect format. Expecting `---` with closing `---`.")

    # Everything after the final `---`
    result.content = line[2]

    let splitMetadata = line[1].splitLines().filterIt(it != "")

    for item in splitMetadata:
      let splitItem = item.split(":")

      if len(splitItem) != 2:
        raise newException(ValueError, "Could not parse metadata. Type malformed.")

      # @TODO: Currently doesn't support non-string types
      result.meta.add((key: splitItem[0], value: formatMetaValue(splitItem[1])))
