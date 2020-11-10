import chartinfo
import clearlevel

import unittest
import options

suite "ChartInfo":
  test "getRating should not throw for any ClearLevel values":
    let defaultChartInfo = ChartInfo(md5: "md5", title: "title", easy: none(float), normal: none(float), hard: none(float), fullcombo: none(float))

    for clearLevel in AllClearLevel:
      discard defaultChartInfo.getRating(clearLevel)