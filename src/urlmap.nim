import strformat
import strutils

import clearlevel as cl
import tabletype as tt

const CombinedUrl* = "https://notmichaelchen.github.io/stella-table-extensions/data/Stellalite-data.json"
const CombinedSubUrl* = "https://notmichaelchen.github.io/stella-table-extensions/data/Stellalite-Sub-data.json"

func getDataUrl*(clearLevel: ClearLevel, tableType: TableType): string =
  doAssert(tableType in DifficultyEstimateTableTypes, fmt"Invalid parameters {clearLevel.title} {tableType.title}")

  let clearLevelPart = clearLevel.title
  let tableTypePart = tableType.title.replace(' ', '-')

  return fmt"https://notmichaelchen.github.io/stella-table-extensions/data/{tableTypePart}-{clearLevelPart}-data.json"