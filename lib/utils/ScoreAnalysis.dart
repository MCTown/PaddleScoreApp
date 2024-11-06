// 传入表名，例如U18组男子_决赛_竞速

import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';

Future<void> importLongDistanceScore(String dbName, List<int> fileBinary) async {
  String tableName = "长距离比赛";
  Database db = await DatabaseManager.getDatabase(dbName);
  var excel = Excel.decodeBytes(fileBinary);
  Map<String, Sheet> sheets = excel.sheets;
  // 录入数据到长距离比赛时间
  var divisions = await getDivisions(dbName);
  // 遍历所有sheet
  // print(divisions);
  for (var division in divisions) {
    var sheet = sheets[division];
    if (sheet == null) {
      throw Exception("表格中没有$division");
    } else {
      // 读取成绩并打印 读取格式为{编号:时间}
      Map<String, String> scores = {};
      var maxRows = sheet.maxRows;
      for (int i = 2; i < maxRows; i++) {
        var id = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
            .value
            .toString();
        var time = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i))
            .value
            .toString();
        // 录入长距离数据库
        db.update(tableName, {"time": time}, where: "id = ?", whereArgs: [id]);
        scores[id] = timeAnalysis(time);
      }
      // 将id按时间排序
      scores = Map.fromEntries(scores.entries.toList()
        ..sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value))));
      var processedGroup = getGroup(scores);
      // processedGroup的key为id，value为组别，将组别录入数据库
      var tables = await DatabaseManager.getTableNames(db);
      var tablesName = ['${division}_初赛_趴板', '${division}_初赛_竞速'];
      for (var tableName in tablesName) {
        if (!tables.contains(tableName)) {
          continue;
        }
        processedGroup.forEach((key, value) {
          db.update(tableName, {"_group": value},
              where: "id = ?", whereArgs: [key]);
        });
      }
    }
  }
  print("All good");
}

String timeAnalysis(String time) {
  // 将时间转换为秒
  if (time == "DNS" || time == 'DNF' || time == 'DSQ') {
    // 如果未参赛则返回99999999
    // -todo 检查该值是否合适
    return "99999999";
  }
  List<String> timeList = time.split(":");
  if (timeList.length == 2) {
    return (int.parse(timeList[0]) * 60 + int.parse(timeList[1])).toString();
  } else if (timeList.length == 3) {
    return (int.parse(timeList[0]) * 3600 +
            int.parse(timeList[1]) * 60 +
            int.parse(timeList[2]))
        .toString();
  } else {
    throw Exception("时间格式不正确");
  }
}

Map<dynamic, dynamic> getGroup(Map<String, String> sortedScores) {
  // 传入按时间递增排序的成绩表，越小越好
  // 返回:
  // {
  //"G1": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
  //"G2": ["11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
  // }
  // print("对$sortedScores进行分组");
  // 蛇形分组
  int personNum = sortedScores.length;
  // 每组最多16人，尽量平均分组，不足16人的组别不分组
  int groupNum = (personNum / 16).ceil();
  // print("$personNum应该分为$groupNum组");
  // 每组的人数
  int groupSize = (personNum / groupNum).ceil();
  // print("每组$groupSize人");
  var result = {};
  // print(sortedScores.keys.toList());
  for (int i = 1; i <= groupNum; i++) {
    int a = i * 2 - 1;
    int b = groupNum * 2 - a;
    int baseNum = (i - 1);
    bool flag = true;
    while (baseNum < personNum) {
      // print(baseNum);
      result[sortedScores.keys.toList()[baseNum]] = i;
      if (flag) {
        //sortedScores的第baseNum个元素即为第baseNum+1名
        // flag为true时baseNum+b
        baseNum += b;
        flag = !flag;
      } else {
        // flag为false时baseNum+a
        baseNum += a;
        flag = !flag;
      }
    }
  }
  // print(result);
  return result;
}
