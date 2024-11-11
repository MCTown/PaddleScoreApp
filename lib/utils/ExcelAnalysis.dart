import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';
import 'DatabaseManager.dart';

// 由以下实体的排列组合生成表
// 1. 组别 2. 比赛进度（预赛、决赛）3. 项目（长距离、趴板、竞速）4. 性别
// 确定生成函数
Future<void> initScoreTable(Database db) async {
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
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else if (athleteCount <= 64) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else if (athleteCount <= 128) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "1/2决赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else if (athleteCount <= 256) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "1/4决赛", competition);
        await generateScoreTable(db, athletes, division, "1/2决赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else {
        throw Exception("运动员数量超过256，无法生成比赛表");
        // print("运动员数量超过256，无法生成比赛表");
      }
    }
  }
}

Future<void> generateScoreTable(Database db, List<Map<String, Object?>> athletes,
    String division, String schedule, String competition) async {
  await db.execute('''
        CREATE TABLE '${division}_${schedule}_$competition' (
          id INT PRIMARY KEY,
          name VARCHAR(255),
          time VARCHAR(255),
          long_distant_time VARCHAR(255),
          _group INT,
          start_position INT
        );
      ''');
  // 生成比赛表
  // 如果是非初赛，则不插入信息
  // 如果是决赛且运动员数量不足16人，则插入信息
  if (schedule == "决赛" && athletes.length <= 16) {
    for (var athlete in athletes) {
      await db.insert(
        '${division}_${schedule}_$competition',
        {
          'id': athlete['id'],
          'name': athlete['name'],
          'time': '0',
          'long_distant_time': '0',
          '_group': 0,
          'start_position': 0,
        },
      );
    }
  }
  if (schedule == "初赛") {
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
          'long_distant_time': '0',
          '_group': group[athlete['id'].toString()],
          'start_position': 0,
        },
      );
    }
  }
}
