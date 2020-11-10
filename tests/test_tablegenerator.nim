include tablegenerator

import unittest

suite "TableGenerator":
  test "makeLevelPair":
    check(makeLevelPair(0) == "0.00...0.50")
    check(makeLevelPair(0.5) == "0.50...1.00")
  
  test "levelToCategory":
    check(levelToCategory(none(float)) == "-")
    check(levelToCategory(some(1.3)) == "1.00...1.50")

  test "getLevelOrder":
    func makeMockChartInfo(rating: float): ChartInfo =
      ChartInfo(md5: "", title: "", easy: some(rating), normal: none(float), hard: none(float), fullcombo: none(float))
    
    let chartInfos = @[
      makeMockChartInfo(-0.2),
      makeMockChartInfo(0),
      makeMockChartInfo(0.2),
      makeMockChartInfo(0.5),
      makeMockChartInfo(1.7),
    ]

    let tableGenerator = TableGenerator(chartInfos: chartInfos, tableType: Stella)

    let levelOrder = tableGenerator.getLevelOrder(Easy)

    require(levelOrder.len == 6)
    check(levelOrder[0] == "-0.50...0.00")
    check(levelOrder[1] == "0.00...0.50")
    check(levelOrder[2] == "0.50...1.00")
    check(levelOrder[3] == "1.00...1.50")
    check(levelOrder[4] == "1.50...2.00")
    check(levelOrder[5] == "-")