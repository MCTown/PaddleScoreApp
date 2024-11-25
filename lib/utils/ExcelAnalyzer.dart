import 'dart:io';

import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';
import 'GlobalFunction.dart';

// 在分析表的时候，Athlete将分为三级，allAthletes指所有运动员，divisionAthletes指某一组的运动员，groupAthletes指某一场比赛的运动员
class ExcelAnalyzer {
  static Future<void> longDistance(String dbName, List<int> fileBinary) async {
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
        //todo reconsider
        // 要实现的是从表格里读取所有运动员的长距离数据，并进行分组
        // 分别录入到长距离成绩表，与所有初赛成绩表中
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
          db.update(tableName, {"time": time},
              where: "id = ?", whereArgs: [id]);
          scores[id] = _timeConvert(time);
        }
        // 将id按时间排序
        scores = Map.fromEntries(scores.entries.toList()
          ..sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value))));

        var processedGroup = _getGroup(scores);
        // processedGroup的key为id，value为组别，将组别录入数据库1
        print("$division的processedGroup为$processedGroup");
        var tables = await DatabaseManager.getTableNames(db);
        // 更新所有已确定人员名单的比赛的group
        var tablesName = [
          '${division}_初赛_趴板',
          '${division}_决赛_趴板',
          '${division}_初赛_竞速',
          '${division}_决赛_竞速'
        ];
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
    print("Import finished, sort starting...");
    // 按分组计算并排序长距离成绩单
    for (var division in divisions) {
      var athletes = await db.rawQuery('''
        SELECT "长距离比赛".id,"长距离比赛".time 
        FROM athletes 
        LEFT JOIN "长距离比赛" 
        ON athletes.id = "长距离比赛".id
        WHERE athletes.division = '$division'
      ''');
      List<Map<String, dynamic>> sortedAthletes = [];
      // 将所有athletes的time转换为s
      athletes.map((athlete) {
        // print("athlete: $athlete ${athlete['time']}");
        sortedAthletes.add({
          "id": athlete['id'],
          "time": _timeConvert(athlete['time'].toString())
        });
      }).toList();
      // 按照time排序
      sortedAthletes
          .sort((a, b) => int.parse(a['time']).compareTo(int.parse(b['time'])));
      // 将排序后的数据录入到数据库中
      for (int i = 0; i < sortedAthletes.length; i++) {
        db.update("长距离比赛", {"long_distant_rank": i + 1},
            where: "id = ?", whereArgs: [sortedAthletes[i]['id']]);
        // 如果时间为99999999则分数为0 todo
        if (sortedAthletes[i]['time'] == "99999999") {
          db.update("athletes", {"long_distance_score": "0"},
              where: "id = ?", whereArgs: [sortedAthletes[i]['id']]);
        } else {
          db.update("athletes", {"long_distance_score": rankToScore(i + 1)},
              where: "id = ?", whereArgs: [sortedAthletes[i]['id']]);
        }
      }
    }

    // 计算并排序长距离成绩单
    // var athletes = await db.query("长距离比赛", columns: ['id', 'time']);
    // List<Map<String, dynamic>> sortedAthletes = [];
    // // 将所有athletes的time转换为s
    // athletes.map((athlete) {
    //   // print("athlete: $athlete ${athlete['time']}");
    //   sortedAthletes.add({
    //     "id": athlete['id'],
    //     "time": _timeConvert(athlete['time'].toString())
    //   });
    // }).toList();
    // // 按照time排序
    // sortedAthletes
    //     .sort((a, b) => int.parse(a['time']).compareTo(int.parse(b['time'])));
    // // 将排序后的数据录入到数据库中
    // for (int i = 0; i < sortedAthletes.length; i++) {
    //   db.update("长距离比赛", {"long_distant_rank": i + 1},
    //       where: "id = ?", whereArgs: [sortedAthletes[i]['id']]);
    //   db.update("athletes", {"long_distance_score": rankToScore(i)},
    //       where: "id = ?", whereArgs: [sortedAthletes[i]['id']]);
    // }
    // print("All done :D");
  }

  static Future<void> initAthlete(
      String dbName, List<int> xlsxFileBytes) async {
    Database db = await DatabaseManager.getDatabase(dbName);
    var excel = Excel.decodeBytes(xlsxFileBytes);
    // print("可用的table：${excel.tables}");
    var tableSelected = excel.tables.keys.first;
    // print("选中的table：$table_selected");
    var table = excel.tables[tableSelected]!;
    // print("表格的行数：${table.maxRows}");
    // 从第二行开始读取数据
    // 将表格中的数据按照长距离的成绩排序
    //todo 重写
    for (int i = 1; i < table.maxRows; i++) {
      var row = table.row(i);
      // 将数据插入到数据库中
      // 如果组别中在黑名单里则跳过
      var blackList = divisionBlackList;
      if (blackList.contains(row[0]?.value.toString())) {
        print("黑名单中的组别，跳过");
        continue;
      }
      // 如果id中含有非数字则跳过
      if (row[1]?.value == null ||
          !RegExp(r'^\d+$').hasMatch(row[1]!.value.toString())) {
        print("id不合法，跳过");
        continue;
      }
      // print("第$i行数据：${row[0]?.value ?? ''} ${row[1]?.value ?? ''} ${row[2]?.value ?? ''} ${row[3]?.value ?? ''}");
      await db.insert(
        'athletes',
        {
          'id': row[1]!.value.toString(),
          'name': row[2]!.value.toString(),
          'team': row[3]!.value.toString(),
          'division': row[0]!.value.toString(),
          'prone_paddle_score': '0',
          'sprint_score': '0',
        },
      );
      // 先处理长距离的表
      await db.insert("长距离比赛", {
        "id": row[1]!.value.toString(),
        "name": row[2]!.value.toString(),
        "time": "0",
        'long_distant_rank': '0'
      });
    }
    await _initScoreTable(db);
  }

  static String _timeConvert(String time) {
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

  static Map<dynamic, dynamic> _getGroup(Map<String, String> sortedScores) {
    // 传入按时间递增排序的成绩表，越小越好
    // print("对$sortedScores进行分组");
    // 蛇形分组
    int personNum = sortedScores.length;
    // 每组最多16人，尽量平均分组，不足16人的组别不分组
    // 组数只能为1,2,4,8,16
    int groupNum = getGroupNum(personNum);
    print("$personNum应该分为$groupNum组");
    // 每组的人数
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

  // 由以下实体的排列组合生成表
// 1. 组别 2. 比赛进度（预赛、决赛）3. 项目（长距离、趴板、竞速）4. 性别
// 确定生成函数
  static Future<void> _initScoreTable(Database db) async {
    // 查询athlete表中有哪些division
    var divisionsRaw = await db.rawQuery('''
    SELECT DISTINCT division FROM athletes
  ''');
    List<String> divisions =
        divisionsRaw.map((row) => row['division'] as String).toList();
    print('查询到的division：$divisions');
    List<String> competitions = ['趴板', '竞速'];
    // print('查询到的competition：$competitions');
    for (var competition in competitions) {
      for (var division in divisions) {
        // 如果分组为非青少年（没有U），且比赛为趴板，则跳过
        if (!RegExp(r'U\d+').hasMatch(division) && competition == '趴板') {
          continue;
        }
        // 先查询满足这三项的运动员数量
        var athletes = (await db.rawQuery('''
          SELECT * FROM athletes
          WHERE division = '$division'
        '''));
        int athleteCount = athletes.length;
        // 如果运动员数量为0则抛出错误 todo
        if (athleteCount == 0) {
          print("比赛项目：$division $competition 没有满足条件的运动员");
          continue;
        }
        print("比赛项目：$division $competition 共有$athleteCount名运动员");
        // 生成比赛表
        if (athleteCount <= 16) {
          await _generateScoreTable(db, athletes, division, "决赛", competition);
        } else if (athleteCount <= 64) {
          await _generateScoreTable(db, athletes, division, "初赛", competition);
          await _generateScoreTable(db, athletes, division, "决赛", competition);
        } else if (athleteCount <= 128) {
          await _generateScoreTable(db, athletes, division, "初赛", competition);
          await _generateScoreTable(
              db, athletes, division, "二分之一决赛", competition);
          await _generateScoreTable(db, athletes, division, "决赛", competition);
        } else if (athleteCount <= 256) {
          await _generateScoreTable(db, athletes, division, "初赛", competition);
          await _generateScoreTable(
              db, athletes, division, "四分之一决赛", competition);
          await _generateScoreTable(
              db, athletes, division, "二分之一决赛", competition);
          await _generateScoreTable(db, athletes, division, "决赛", competition);
        } else {
          throw Exception("运动员数量超过256，无法生成比赛表");
          // print("运动员数量超过256，无法生成比赛表");
        }
      }
    }
  }

  static Future<void> _generateScoreTable(
      Database db,
      List<Map<String, Object?>> athletes,
      String division,
      String schedule,
      String competition) async {
    await db.execute('''
        CREATE TABLE '${division}_${schedule}_$competition' (
          id INT PRIMARY KEY,
          name VARCHAR(255),
          time VARCHAR(255),
          _group INT
        );
      ''');
    // 生成比赛表
    // 如果是非初赛，则不插入信息
    // 如果是决赛且运动员数量不足16人，则插入信息
    // if (schedule == "决赛" && athletes.length <= 16) {
    //   for (var athlete in athletes) {
    //     await db.insert(
    //       '${division}_${schedule}_$competition',
    //       {
    //         'id': athlete['id'],
    //         'name': athlete['name'],
    //         'time': '0',
    //         '_group': 0,
    //       },
    //     );
    //   }
    // }
    if (schedule == "初赛" || (schedule == "决赛" && athletes.length <= 16)) {
      // 生成分组
      var group = <String, int>{};
      for (var i = 0; i < athletes.length; i++) {
        group[athletes[i]['id'].toString()] = i ~/ 16;
      }
      // 插入信息
      for (var athlete in athletes) {
        await db.insert(
          '${division}_${schedule}_$competition',
          {
            'id': athlete['id'],
            'name': athlete['name'],
            'time': '0',
            '_group': group[athlete['id'].toString()],
          },
        );
      }
    }
  }

  static Future<String> _getNextTableName(
      String dbName, String division, CType c, SType s) async {
    Database db = await DatabaseManager.getDatabase(dbName);
    if (s == SType.firstRound) {
      String tableName =
          "${division}_${sTypeTranslate(s)}_${cTypeTranslate(c)}";
      var athletes = await db.query("'$tableName'", columns: ['id']);
      var athletesNum = athletes.length;
      if (athletesNum == 0) {
        throw Exception("致命错误：在进行初赛成绩导入时没有运动员");
      }
      if (athletesNum <= 16) {
        throw Exception("致命错误：决赛无需获取下一场比赛表名");
      } else if (athletesNum <= 64) {
        return "${division}_决赛_${cTypeTranslate(c)}";
      } else if (athletesNum <= 128) {
        return "${division}_二分之一决赛_${cTypeTranslate(c)}";
      } else if (athletesNum <= 256) {
        return "${division}_四分之一决赛_${cTypeTranslate(c)}";
      }
    } else {
      if (s == SType.semifinals) {
        return "${division}_决赛_${cTypeTranslate(c)}";
      } else if (s == SType.quarterfinals) {
        return "${division}_二分之一决赛_${cTypeTranslate(c)}";
      } else if (s == SType.roundOf16) {
        return "${division}_四分之一决赛_${cTypeTranslate(c)}";
      }
    }
    throw Exception("致命错误：无法获取下一场比赛表名");
  }

  static int _getPromotionAthleteNum(int athleteNum) {
    if (athleteNum <= 16) {
      throw Exception("决赛无需晋级");
    } else if (athleteNum <= 64) {
      return 16;
    } else if (athleteNum <= 128) {
      return 64;
    } else if (athleteNum <= 256) {
      return 128;
    } else {
      throw Exception("运动员数量超过256，无法获取晋级人数");
    }
  }

  static Future<void> generic(String division, List<int> fileBinary, CType c,
      SType s, String dbName) async {
    // 需求：导入趴板或竞速的成绩表
    // 确定下一场比赛的position与_group
    print('导入通用比赛成绩');
    Database db = await DatabaseManager.getDatabase(dbName);
    var excel = Excel.decodeBytes(fileBinary);
    var sheets = excel.sheets;
    var tableName = "${division}_${sTypeTranslate(s)}_${cTypeTranslate(c)}";
    var a = await db.query("'$tableName'", columns: ['id']);
    int athletesNum = a.length;
    // 遍历所有sheet
    if (s == SType.finals) {
      // 若为决赛则直接录入总成绩即可 todo
    }

    Map<String, String> promotionScore = {};
    for (var sheetKey in sheets.keys) {
      var sheet = sheets[sheetKey];
      if (sheet == null) {
        throw Exception("表格中没有$sheetKey");
      }
      var maxRows = sheet.maxRows;
      Map<String, String> scores = {};
      for (int i = 2; i < maxRows; i++) {
        var id = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
            .value
            .toString();
        var time = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i))
            .value
            .toString();
        // 录入相应数据库
        db.update("'$tableName'", {"time": time},
            where: "id = ?", whereArgs: [id]);
        scores[id] = _timeConvert(time);
      }
      const column = ["prone_paddle_score", "sprint_score"];
      var matchType = '';
      if (c == CType.sprint) {
        matchType = column[1];
      } else {
        matchType = column[0];
      }
      // 若为决赛则直接录入
      if (s == SType.finals) {
        scores = Map.fromEntries(scores.entries.toList()
          ..sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value))));
        var sortedAthletes = scores.keys.toList();
        for (int i = 0; i < sortedAthletes.length; i++) {
          // 录入总分
          db.update('athletes', {matchType: rankToScore(i)},
              where: "id = ?", whereArgs: [sortedAthletes[i]]);
        }
      } else {
        print("处理初赛");
        // 若为初赛则晋级
        scores = Map.fromEntries(scores.entries.toList()
          ..sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value))));
        var sortedAthletes = scores.keys.toList();
        int promotionNum = _getPromotionAthleteNum(athletesNum);
        print(
            "比赛${division}_${sTypeTranslate(s)}_${cTypeTranslate(c)}的晋级人数为：$promotionNum");
        print(promotionNum);
        print(sortedAthletes);
        print(tableName);
        // 处理晋级的运动员
        for (int i = 0; i < promotionNum / getGroupNum(athletesNum); i++) {
          // 将该运动员添加到promotionScore中
          promotionScore[sortedAthletes[i]] = i.toString();
        }
        // 处理未晋级运动员
        for (int i = (promotionNum / getGroupNum(athletesNum)).ceil();
            i < scores.length;
            i++) {
          db.update('athletes', {matchType: rankToScore(i)},
              where: "id = ?", whereArgs: [sortedAthletes[i]]);
          print("未晋级运动员：${sortedAthletes[i]}");
        }
      }
    }
    // 处理晋级的运动员p2
    print(promotionScore);
    var groups = _getGroup(promotionScore);
    print(groups);
    var targetTable = await _getNextTableName(dbName, division, c, s);
    print("将晋级运动员录入到$targetTable中");
    for (var athleteID in groups.keys) {
      // 获取名字
      var name = (await db.query('athletes',
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [athleteID]))[0]['name'];
      db.insert("'$targetTable'", {
        'id': athleteID,
        'name': name,
        'time': '0',
        '_group': groups[athleteID]
      });
    }
  }
}
