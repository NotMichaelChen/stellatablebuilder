import json
import strformat
import sugar
import sequtils
import strutils

import tabletype
import urlmap

import bmslib/bmstable/tableinfo

const tableSuffix = "table.html"
const tableSubSuffix = "table_sub.html"

proc combineTables*(tableType: TableType): (JsonNode, JsonNode) =
  if tableType notin CombinedTableTypes:
    raise newException(Exception, fmt"Invalid table type for table combiner: {tableType.title}")

  let (urlSuffix, dataUrl) =
    if tableType == Combined:
      (tableSuffix, CombinedUrl)
    elif tableType == CombinedSub:
      (tableSubSuffix, CombinedSubUrl)
    else:
      raise newException(Exception, fmt"Invalid table type for table combiner: {tableType.title}")

  let satelliteTable = initTableInfo(fmt"https://stellabms.xyz/sl/{urlSuffix}")
  let stellaTable = initTableInfo(fmt"https://stellabms.xyz/st/{urlSuffix}")
  
  let header = %*{
    "name": tableType.title,
    "symbol": tableType.symbol,
    "data_url": dataUrl,
    "level_order": (0..24).toSeq.map(i => $i)
  }

  let modifiedStellaData =
    stellaTable
      .dataJson
      .getElems
      .map(proc(chartObj: JsonNode): JsonNode =
        chartObj["level"] = %*($(chartObj["level"].getStr().parseInt + 13))
        chartObj
      )

  let satelliteData = satelliteTable.dataJson.getElems

  let combinedData = %*(satelliteData & modifiedStellaData)

  (header, combinedData)
