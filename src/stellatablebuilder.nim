import strutils
import os
import strformat
import json
import httpclient

import diffscraper
import tabletype as tt
import clearlevel as cl
import tablecombiner
import tablegenerator
import simple_parseopt

type ProgramOptions = object
  outputPath: string
  doUpload: bool

proc outputTableFiles(tableTitle: string, header: string, data: string, outputPath: string)
proc generateDifficultyEstimateTables(tableType: TableType, programOpts: ProgramOptions)
proc generateCombinedTable(tableType: TableType, programOpts: ProgramOptions)
proc generateTable(tableType: TableType, programOpts: ProgramOptions)
proc uploadFiles(tableTitle: string, header: string, data: string)

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
    doUpload = false {.
      aka("upload")
      info("Whether to upload files directly to dropbox or not, defaults to false")
    .}
  
  let programOpts = ProgramOptions(outputPath: options.outputPath, doUpload: options.doUpload)
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
  let chartList = scrapeDifficultyEstimate(tableType)
  let tableGenerator = initTableGenerator(chartList, tableType)

  for clearlevel in AllClearLevel:
    if programOpts.doUpload:
      uploadFiles(
        fmt"{tableType.title}-{clearlevel.title}",
        tableGenerator.getHeaderJson(clearlevel).pretty,
        tableGenerator.getDataJson(clearlevel).pretty,
      )
    else:
      outputTableFiles(
        fmt"{tableType.title}-{clearlevel.title}",
        tableGenerator.getHeaderJson(clearlevel).pretty,
        tableGenerator.getDataJson(clearlevel).pretty,
        programOpts.outputPath
      )

proc generateCombinedTable(tableType: TableType, programOpts: ProgramOptions) =
  let (header, data) = combineTables(tableType)
  
  if programOpts.doUpload:
    uploadFiles(
      tableType.title,
      header.pretty,
      data.pretty,
    )
  else:
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

proc uploadFiles(tableTitle: string, header: string, data: string) =
  doAssert(existsEnv("DROPBOX_KEY"), "No dropbox key supplied - set the DROPBOX_KEY environment variable")

  let formattedTitle = tableTitle.replace(" ", "-")
  let dropboxKey = getEnv("DROPBOX_KEY")

  proc upload(client: HttpClient, path: string, dropboxKey: string, data: string) =
    let body = %*{
      "path": path,
      "mode": "overwrite",
      "mute": true
    }

    client.headers = newHttpHeaders({
      "Content-Type": "application/octet-stream",
      "Authorization": fmt"Bearer {dropboxKey}",
      "Dropbox-API-Arg": $body
    })

    let res = client.post("https://content.dropboxapi.com/2/files/upload", data)
    echo res.body
  
  let client = newHttpClient()
  defer: client.close()
  
  upload(client, fmt"/Stella/{formattedTitle}-header.json", dropboxKey, header)
  upload(client, fmt"/Stella/{formattedTitle}-data.json", dropboxKey, data)