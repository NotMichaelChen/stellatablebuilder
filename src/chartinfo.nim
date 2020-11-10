import options
import strformat
import clearlevel

type ChartInfo* = object
  md5*: string
  title*: string
  easy*: Option[float]
  normal*: Option[float]
  hard*: Option[float]
  fullcombo*: Option[float]

func getRating*(chartInfo: ChartInfo, clearLevel: ClearLevel): Option[float] =
  if clearLevel == Easy:
    return chartInfo.easy
  elif clearLevel == Normal:
    return chartInfo.normal
  elif clearLevel == Hard:
    return chartInfo.hard
  elif clearLevel == FullCombo:
    return chartInfo.fullcombo
  else:
    raise newException(Exception, fmt"Invalid ClearLevel object passed, title: {clearLevel.title}")