import 'dart:ffi';

import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:paddle_score_app/utils/ExcelAnalyzer.dart';
import 'package:paddle_score_app/utils/ExcelGenerator.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

class DataHelper {
  // 传入报名表的Excel文件
  static Future<void> loadExcelFileToAthleteDatabase(
      String dbName, List<int> xlsxFileBytes) async {
    return ExcelAnalyzer.initAthlete(dbName, xlsxFileBytes);
  }

  // 生成长距离比赛成绩表
  static Future<List<int>?> generateLongDistanceScoreExcel(
      String dbName) async {
    // 生成长距离比赛Excel
    // 读取所有数据表
    return ExcelGenerator.longDistance(dbName);
  }

  // 导入长距离比赛成绩
  static Future<void> importLongDistanceScore(
      String dbName, List<int> fileBinary) async {
    return ExcelAnalyzer.longDistance(dbName, fileBinary);
  }

  // 生成趴板和竞速的Excel
  // 四个参数分别为组别、比赛进度、项目、水域类型、数据库名
  static Future<List<int>?> generateGenericExcel(
      String division, CType c, SType s, String dbName) async {
    return ExcelGenerator.generic(division, c, s, dbName);
  }

  // 选择并导入趴板或竞速成绩表的Excel
  static Future<void> importGenericCompetitionScore(String division,
      List<int> fileBinary, CType c, SType s, String dbName) async {
    return ExcelAnalyzer.generic(division, fileBinary, c, s, dbName);
  }
}
