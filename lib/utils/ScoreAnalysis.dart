// 传入表名，例如U18组男子_决赛_竞速

import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';

// 导入除了长距离以外的成绩
importGenericScore(String division, CType c, SType s, String dbName) async {
  var competitionType = cTypeTranslate(c);
  var scheduleType = sTypeTranslate(s);
  // print("尝试导入$competitionType $scheduleType 的比赛成绩");
  var tableName = "${division}_${scheduleType}_$competitionType";
  print("尝试导入$tableName");
  Database db = await DatabaseManager.getDatabase(dbName);
}

// 将[hh,mm,ss]格式的时间转换为秒
String timeAnalysis(String time) {
  // 将时间转换为秒
  if (time == "DNS" || time == 'DNF' || time == 'DSQ') {
    // 如果未参赛则返回99999999
    // -todo 检查该值是否合适
    return "99999999";
  }
  List<String> timeList = time.split(":");
  if (timeList.length == 2) {
    return (timeList[0] * 60 + timeList[1]).toString();
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
  print(result);
  return result;
}

