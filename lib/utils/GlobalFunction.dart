import 'dart:io';

import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<String> getFilePath(String? fileName) async {
  final directory = await getApplicationDocumentsDirectory();
// 若PaddleScoreData文件夹不存在，则创建
  final path = '${directory.path}/PaddleScoreData';
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync();
  }
  if (fileName == null) {
    return path;
  }
  return '$path/$fileName';
}

Future<List<String>> getDivisions(String dbName) async {
  Database db = await DatabaseManager.getDatabase(dbName);
  List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT division FROM athletes');
  return maps.map((map) => map['division'] as String).toList();
}

enum CType { pronePaddle, sprint }

String cTypeTranslate(CType c) {
  if (c == CType.pronePaddle) {
    return "趴板";
  } else if (c == CType.sprint) {
    return "竞速";
  } else {
    throw "传入错误的比赛类型";
  }
}

Future<int> getAthleteCountByDivision(String dbName, String division) async {
Database db = await DatabaseManager.getDatabase(dbName);
List<Map<String, dynamic>> maps = await db.rawQuery('SELECT COUNT(*) FROM athletes WHERE division = ?', [division]);
return Sqflite.firstIntValue(maps)!;
}

enum SType { firstRound, roundOf16, quarterfinals, semifinals, finals }

String sTypeTranslate(SType s) {
  if (s == SType.firstRound) {
    return "初赛";
  } else if (s == SType.roundOf16) {
    return "1/8决赛";
  } else if (s == SType.quarterfinals) {
    return "1/4决赛";
  } else if (s == SType.semifinals) {
    return "1/2决赛";
  } else if (s == SType.finals) {
    return "决赛";
  } else {
    throw "传入错误的比赛类型";
  }
}

enum WType { dynamic, static }

String wTypeTranslate(WType w) {
  if (w == WType.dynamic) {
    return "静水";
  } else if (w == WType.static) {
    return "动水";
  } else {
    throw "传入错误的水域类型";
  }
}

const List<String> divisionBlackList = ['仅团体','接力赛','龙板'];