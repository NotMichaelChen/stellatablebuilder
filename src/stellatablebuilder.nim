import strutils
import os
import strformat
import json

import diffscraper
import tabletype as tt
import clearlevel as cl
import tablecombiner
import tablegenerator
import simple_parseopt

type ProgramOptions = object
  outputPath: string

proc outputTableFiles(tableTitle: string, header: string, data: string, outputPath: string)
proc generateDifficultyEstimateTables(tableType: TableType, programOpts: ProgramOptions)
proc generateCombinedTable(tableType: TableType, programOpts: ProgramOptions)
proc generateTable(tableType: TableType, programOpts: ProgramOptions)

when isMainModule:
  echo("Hello, World!")

  dashDashParameters()
  let options = getOptions:
    tableType = "all" {.
      aka("table-type")
      info("Which table to build, defaults to everything")
    .}
    outputPath = "" {.
      aka("output-path")
      info("Where to output the generated json. Ignored if --upload is set")
    .}

  let programOpts = ProgramOptions(outputPath: options.outputPath)
  let tableType = parseTableType(options.tableType)

  if tableType == All:
    for table in AllTableTypes:
      generateTable(table, programOpts)
  else:
    generateTable(tableType, programOpts)

proc generateTable(tableType: TableType, programOpts: ProgramOptions) =
  if tableType in DifficultyEstimateTableTypes:
    generateDifficultyEstimateTables(tableType, programOpts)
  elif tableType in CombinedTableTypes:
    generateCombinedTable(tableType, programOpts)

proc generateDifficultyEstimateTables(tableType: TableType, programOpts: ProgramOptions) =
  let chartList = ingestChartInfos(tableType)
  let tableGenerator = initTableGenerator(chartList, tableType)

  for clearlevel in AllClearLevel:
    outputTableFiles(
      fmt"{tableType.title}-{clearlevel.title}",
      tableGenerator.getHeaderJson(clearlevel).pretty,
      tableGenerator.getDataJson(clearlevel).pretty,
      programOpts.outputPath
    )

proc generateCombinedTable(tableType: TableType, programOpts: ProgramOptions) =
  let (header, data) = combineTables(tableType)

  outputTableFiles(
    tableType.title,
    header.pretty,
    data.pretty,
    programOpts.outputPath
  )

proc outputTableFiles(tableTitle: string, header: string, data: string, outputPath: string) =
  let formattedTitle = tableTitle.replace(" ", "-")

  writeFile(outputPath / fmt"{formattedTitle}-header.json", header)
  writeFile(outputPath / fmt"{formattedTitle}-data.json", data)