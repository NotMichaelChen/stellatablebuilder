import strformat

import clearlevel as cl
import tabletype as tt

const CombinedUrl* = "https://dl.dropboxusercontent.com/s/gpbgc5yawsit7mw/Stellalite-data.json"
const CombinedSubUrl* = "https://dl.dropboxusercontent.com/s/r32fcdpxy4gtcel/Stellalite-Sub-data.json"

func getUrl*(clearLevel: ClearLevel, tableType: TableType): string =
  if clearLevel == Easy and tableType == Stella:
    "https://dl.dropboxusercontent.com/s/qadk01wk8239ox3/Stella-EASY-data.json"
  elif clearLevel == Normal and tableType == Stella:
    "https://dl.dropboxusercontent.com/s/i202ng1qbbewnop/Stella-NORMAL-data.json"
  elif clearLevel == Hard and tableType == Stella:
    "https://dl.dropboxusercontent.com/s/hmamx5bblu2ovhv/Stella-HARD-data.json"
  elif clearLevel == FullCombo and tableType == Stella:
    "https://dl.dropboxusercontent.com/s/sqpfy06ihcd9go2/Stella-FULLCOMBO-data.json"

  elif clearLevel == Easy and tableType == Satellite:
    "https://dl.dropboxusercontent.com/s/pf2ax7wwoseuazn/Satellite-EASY-data.json"
  elif clearLevel == Normal and tableType == Satellite:
    "https://dl.dropboxusercontent.com/s/qh1span06tgqu37/Satellite-NORMAL-data.json"
  elif clearLevel == Hard and tableType == Satellite:
    "https://dl.dropboxusercontent.com/s/81nuj13zhjnvp37/Satellite-HARD-data.json"
  elif clearLevel == FullCombo and tableType == Satellite:
    "https://dl.dropboxusercontent.com/s/iohlmxffac3l65x/Satellite-FULLCOMBO-data.json"

  elif clearLevel == Easy and tableType == DPSatellite:
    "https://dl.dropboxusercontent.com/s/2oy15p04z8aewsx/DP-Satellite-EASY-data.json"
  elif clearLevel == Normal and tableType == DPSatellite:
    "https://dl.dropboxusercontent.com/s/4vg2832j4whvyyc/DP-Satellite-NORMAL-data.json"
  elif clearLevel == Hard and tableType == DPSatellite:
    "https://dl.dropboxusercontent.com/s/fqbppvbr0bj4f23/DP-Satellite-HARD-data.json"
  elif clearLevel == FullCombo and tableType == DPSatellite:
    "https://dl.dropboxusercontent.com/s/yq5zoh5x11kcifv/DP-Satellite-FULLCOMBO-data.json"
  else:
    raise newException(Exception, fmt"Invalid parameters {clearLevel.title} {tableType.title}")