import json
import strformat
import options
import sugar
import math
import sequtils
import strutils
import algorithm

import chartinfo
import tabletype
import clearlevel
import urlmap

type TableEntry = object
  md5: string
  title: string
  level: string
  levelLowerBound: float
  originalLevel: string

type TableGenerator* = object
  chartInfos: seq[ChartInfo]
  tableType: TableType

func makeLevelPair(lower: float): string
func getLevelOrder(t: TableGenerator, clearLevel: ClearLevel): seq[string]
func levelToCategory(level: Option[float]): string

# TODO: instead of taking a seq[ChartInfo] and TableType, can this take a seq of md5, title, rating instead?
proc initTableGenerator*(chartInfos: seq[ChartInfo], tableType: TableType): TableGenerator =
  doAssert(tableType in DifficultyEstimateTableTypes, fmt"Invalid table type for table generator: {tableType}")

  TableGenerator(chartInfos: chartInfos, tableType: tableType)

func getHeaderJson*(t: TableGenerator, clearLevel: ClearLevel): JsonNode =
  %*
    {
      "name": fmt"{t.tabletype.title} {clearLevel.title}",
      "symbol": fmt"{clearLevel.symbol}-{t.tabletype.symbol}",
      "data_url": urlmap.getDataUrl(clearLevel, t.tableType),
      "level_order": t.getLevelOrder(clearLevel)
    }

func getDataJson*(t: TableGenerator, clearLevel: ClearLevel): JsonNode =
  var tableEntries = t.chartInfos
    .map(proc(chartInfo: ChartInfo): TableEntry =
      let rawLevel = chartInfo.getRating(clearLevel)
      TableEntry(
        md5: chartInfo.md5,
        title: chartInfo.title,
        originalLevel: chartInfo.level,
        level: levelToCategory(rawLevel),
        levelLowerBound: rawLevel.map(l => floor(l*2.0) / 2.0).get(Inf)
      )
    )

  tableEntries.sort(proc(lhs, rhs: TableEntry): int =
    result = cmp(lhs.levelLowerBound, rhs.levelLowerBound)
    if result == 0:
      result = cmpIgnoreCase(lhs.title, rhs.title)
  )

  # TODO: hacky - how to avoid serializing levelLowerBound?
  type TableEntryJson = object
    md5: string
    title: string
    level: string
    comment: string

  return %*tableEntries.map(tableEntry => TableEntryJson(
    md5: tableEntry.md5,
    title: tableEntry.title,
    level: tableEntry.level,
    comment: fmt"{t.tableType.symbol}{tableEntry.originalLevel}"
  ))

func getLevelOrder(t: TableGenerator, clearLevel: ClearLevel): seq[string] =
  let difficultyList = t.chartInfos
    .map(chartInfo => chartInfo.getRating(clearLevel))
    .filter(diffValue => diffValue.isSome)
    .map(diffValue => diffValue.get)
  
  let lowestDoubled = int(floor(difficultyList[difficultyList.minIndex] * 2))
  let highestDoubled = int(ceil(difficultyList[difficultyList.maxIndex] * 2))

  (lowestDoubled..<highestDoubled).toSeq.map(i => makeLevelPair(float(i)/2.0)) & "-"

func makeLevelPair(lower: float): string =
  let upper = lower + 0.5
  fmt"{lower:.2f}...{upper:.2f}"

func levelToCategory(level: Option[float]): string =
  level.map(l => makeLevelPair(floor(l*2.0) / 2.0)).get("-")
