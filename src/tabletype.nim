import strutils
import strformat

type TableType* = object
  title*: string
  symbol*: string
  urlsymbol*: string

const All* = TableType(title: "", symbol: "", urlsymbol: "")
const Stella* = TableType(title: "Stella", symbol: "st", urlsymbol: "st")
const Satellite* = TableType(title: "Satellite", symbol: "sl", urlsymbol: "sl")
const DPSatellite* = TableType(title: "DP Satellite", symbol: "sl", urlsymbol: "dp")
const Combined* = TableType(title: "Stellalite", symbol: "stl", urlsymbol: "")
const CombinedSub* = TableType(title: "Stellalite Sub", symbol: "stl", urlsymbol: "")

const AllTableTypes* = [All, Stella, Satellite, DPSatellite, Combined, CombinedSub]

const DifficultyEstimateTableTypes* = [Stella, Satellite, DPSatellite]

const CombinedTableTypes* = [Combined, CombinedSub]

# const RejectsTableTypes* = [SatelliteRejects, StellaRejects]

func parseTableType*(tableType: string): TableType =
  let lowerTableType = tableType.toLowerAscii()

  case lowerTableType
  of "all":
    All
  of "stella":
    Stella
  of "satellite":
    Satellite
  of "dp-satellite":
    DPSatellite
  of "combined":
    Combined
  of "combined-sub":
    CombinedSub
  else:
    raise newException(Exception, fmt"Unable to parse string into TableType: {tableType}")