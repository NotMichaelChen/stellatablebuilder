import httpclient
import json
import strutils
import options
import sugar
import strformat

import chartinfo
import tabletype as tt

proc scrapeDifficultyEstimate*(tableType: TableType): seq[ChartInfo] =
  doAssert(tableType in DifficultyEstimateTableTypes, fmt"Invalid table type to scrape: {tableType.title}")

  let client = newHttpClient()
  defer: client.close()
  client.headers = newHttpHeaders({"Content-Type": "application/json"})

  var pageNumber = 1
  var chartInfoSeq: seq[ChartInfo]

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
        ChartInfo(
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
