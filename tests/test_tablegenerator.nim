include tablegenerator

import unittest

suite "TableGenerator.getDataJson":
  test "should sort charts by level category, then by title":
    func makeMockChartInfo(md5: string, title: string, rating: float): ChartInfo =
      ChartInfo(md5: md5, title: title, easy: some(rating), normal: none(float), hard: none(float), fullcombo: none(float))

    let testChartInfos = @[
      makeMockChartInfo("md5-1", "Title1", 0.1),
      makeMockChartInfo("md5-2", "title2", 0.1),
      makeMockChartInfo("md5-3", "Title3", 0.05),
      makeMockChartInfo("md5-4", "title4", 1.3),
    ]

    let tableGenerator = TableGenerator(chartInfos: testChartInfos, tableType: Stella)

    let dataJson = tableGenerator.getDataJson(Easy)

    let expectedDataJson = %*[
      {
        "md5": "md5-1",
        "title": "Title1",
        "level": "0.00...0.50"
      },
      {
        "md5": "md5-2",
        "title": "title2",
        "level": "0.00...0.50"
      },
      {
        "md5": "md5-3",
        "title": "Title3",
        "level": "0.00...0.50"
      },
      {
        "md5": "md5-4",
        "title": "title4",
        "level": "1.00...1.50"
      }
    ]

    check(dataJson == expectedDataJson)

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

    check(levelOrder == @[
      "-0.50...0.00",
      "0.00...0.50",
      "0.50...1.00",
      "1.00...1.50",
      "1.50...2.00",
      "-"
    ])