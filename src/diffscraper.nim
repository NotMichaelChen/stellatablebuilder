import httpclient
import json
import strutils
import options
import sequtils
import sugar
import strformat
import tables

import bmslib/bmstable/tableinfo

import chartinfo
import tabletype as tt

type RawChartInfo = object
  md5: string
  title: string
  easy: Option[float]
  normal: Option[float]
  hard: Option[float]
  fullcombo: Option[float]

proc scrapeDifficultyEstimate*(tableType: TableType): seq[RawChartInfo]
proc annotateLevel(rawChartInfos: seq[RawChartInfo], tableType: TableType): seq[ChartInfo]

proc ingestChartInfos*(tableType: TableType): seq[ChartInfo] =
  let rawChartInfos = scrapeDifficultyEstimate(tableType)
  return annotateLevel(rawChartInfos, tableType)

proc scrapeDifficultyEstimate(tableType: TableType): seq[RawChartInfo] =
  doAssert(tableType in DifficultyEstimateTableTypes, fmt"Invalid table type to scrape: {tableType.title}")

  let client = newHttpClient()
  defer: client.close()
  client.headers = newHttpHeaders({"Content-Type": "application/json"})

  var pageNumber = 1
  var chartInfoSeq: seq[RawChartInfo]

  #TODO: Decide whether or not this should be refactored
  while true:
    let body = %*{
      "table": tableType.urlsymbol,
      "page": $pageNumber
    }

    let response = client.request("https://stellabms.xyz/api/recommend", httpMethod = HttpPost, body = $body)

    doAssert(response.status == "200 OK", "Got \"$#\" when attempting to access recommend api" % [response.status])

    let jsonResponse = parseJson(response.body)
    let source = jsonResponse["source"]

    doAssert(source.kind == JArray, "Expected source to be JArray, instead was $#" % [$(source.kind)])

    let sourceArray = source.getElems
    if sourceArray.len == 0:
      break

    for chartInfo in sourceArray:
      let ec = option(chartInfo{"ec"}).map((value) => value.getFloat)
      let gc = option(chartInfo{"gc"}).map((value) => value.getFloat)
      let hc = option(chartInfo{"hc"}).map((value) => value.getFloat)
      let fc = option(chartInfo{"fc"}).map((value) => value.getFloat)

      chartInfoSeq.add(
        RawChartInfo(
          md5: chartInfo["md5"].getStr,
          title: chartInfo["title"].getStr,
          easy: ec,
          normal: gc,
          hard: hc,
          fullcombo: fc
        )
      )
    
    pageNumber += 1

  return chartInfoSeq

proc annotateLevel(rawChartInfos: seq[RawChartInfo], tableType: TableType): seq[ChartInfo] =
  let stellaTableInfo = initTableInfo(fmt"https://stellabms.xyz/{tableType.urlSymbol}/table.html")

  let hashToLevelMap = stellaTableInfo
    .dataJson
    .getElems
    .map((chartObj) => (
      (chartObj["md5"].getStr, chartObj["level"].getStr)
    ))
    .toTable

  rawChartInfos
    .map(rawChartInfo => ChartInfo(
      md5: rawChartInfo.md5,
      title: rawChartInfo.title,
      level: hashToLevelMap.getOrDefault(rawChartInfo.md5),
      easy: rawChartInfo.easy,
      normal: rawChartInfo.normal,
      hard: rawChartInfo.hard,
      fullcombo: rawChartInfo.fullcombo
    ))
    .filter(chartInfo => chartInfo.level != "")