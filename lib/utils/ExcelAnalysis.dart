import 'dart:ffi';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';

// 传入数据库对象，让用户选择一个excel文件，然后将excel文件中的数据导入到数据库中
Future<void> loadExcelFileToAthleteDatabase(
    String dbName, List<int> xlsxFileBytes) async {
  // FilePickerResult? result = await FilePicker.platform.pickFiles(
  //   type: FileType.custom,
  //   allowedExtensions: ['xlsx'],
  //   withData: true,
  //   allowMultiple: false, // Ensure single file selection
  // );
  // if (result != null) {
  //   print("文件已选择${result.paths.first as String}");
  //   var bytes = File(result.paths.first as String).readAsBytesSync();
  Database db = await DatabaseManager.getDatabase(dbName);
  var excel = Excel.decodeBytes(xlsxFileBytes);
  print("可用的table：${excel.tables}");
  var table_selected = excel.tables.keys.first;
  print("选中的table：$table_selected");
  var table = excel.tables[table_selected]!;
  print("表格的行数：${table.maxRows}");
  // 从第二行开始读取数据
  for (int i = 1; i < table.maxRows; i++) {
    var row = table.row(i);
    // 将数据插入到数据库中
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
        'long_distant_score': '0',
        'prone_paddle_score': '0',
        'sprint_score': '0',
      },
    );
    // 先处理长距离的表
    await db.insert("长距离比赛", {
      "id": row[1]!.value.toString(),
      "name": row[2]!.value.toString(),
      "time": "0"
    });
    // print("运动员录入完成");
  }
  await initScoreTable(db);
  return;
}
// else {
//   print("用户未选择文件，退出");
//   return;
// }

// 由以下实体的排列组合生成表
// 1. 组别 2. 比赛进度（预赛、决赛）3. 项目（长距离、躺板、竞速）4. 性别
// 确定生成函数
Future<void> initScoreTable(Database db) async {
  // 查询athlete表中有哪些division
  var divisions_raw = await db.rawQuery('''
    SELECT DISTINCT division FROM athletes
  ''');
  List<String> divisions =
      divisions_raw.map((row) => row['division'] as String).toList();
  print('查询到的division：$divisions');
  List<String> competitions = ['躺板', '竞速'];
  // print('查询到的competition：$competitions');
  for (var competition in competitions) {
    for (var division in divisions) {
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
      if (athleteCount <= 64) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else if (athleteCount <= 128) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "1/4决赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else if (athleteCount <= 256) {
        await generateScoreTable(db, athletes, division, "初赛", competition);
        await generateScoreTable(db, athletes, division, "1/4决赛", competition);
        await generateScoreTable(db, athletes, division, "1/2决赛", competition);
        await generateScoreTable(db, athletes, division, "决赛", competition);
      } else {
        print("运动员数量超过256，无法生成比赛表");
      }
    }
  }
}

Future<void> generateScoreTable(Database db, List<Map<String, Object?>> athlete,
    String division, String schedule, String competition) async {
  await db.execute('''
        CREATE TABLE '${division}_${schedule}_$competition' (
          id INT PRIMARY KEY,
          name VARCHAR(255),
          time VARCHAR(255),
          _group INT
        );
      ''');
  // 生成比赛表
  for (var i = 0; i < athlete.length; i++) {
    await db.execute('''
        INSERT INTO '${division}_${schedule}_$competition' (id, name, time)
        VALUES (${athlete[i]['id']}, '${athlete[i]['name']}', '0');
      ''');
  }
}
