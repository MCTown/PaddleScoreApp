import 'dart:typed_data';

import 'package:excel/excel.dart';

class CreateRaceExcelChecker {
  /// 获取有哪些组别
  /// @param fileBinary Excel文件的二进制数据
  static Future<List<String>> getDivisions(List<int> fileBinary) async {
    // 组别在Excel文件的第一列
    // 读取Excel文件
    // 读取第一列
    var excel = Excel.decodeBytes(fileBinary);
    var sheet = excel.tables.keys.first;
    List<CellValue?> divisionColumn =
        excel.tables[sheet]!.rows.map((e) => e[0]?.value).toList();
    // 去掉第一行
    divisionColumn.removeAt(0);
    // 转换为List<String>
    List<String> divisions = divisionColumn.map((e) => e.toString()).toList();
    // 去重
    divisions = divisions.toSet().toList();
    return divisions;
  }

  static getAthleteCount(List<int> fileBinary) {
    // 读取Excel文件
    var excel = Excel.decodeBytes(fileBinary);
    var sheet = excel.tables.keys.first;
    // 输出行数
    return excel.tables[sheet]!.maxRows - 1;
  }

  /// 检查Excel文件是否符合规范
  /// 检查规则：1. 第二列除开第一行外不能有空值
  static ValidExcelResult validExcel(Uint8List readAsBytesSync) {
    ValidExcelResult result = ValidExcelResult();
    var excel = Excel.decodeBytes(readAsBytesSync);
    var sheet = excel.tables.keys.first;
    var rows = excel.tables[sheet]!.rows;

    /// 验证ID
    for (var i = 1; i < rows.length; i++) {
      if (rows[i][1]?.value == null) {
        result.numberValidated = false; // 有空值
      }
    }
    return result;
  }
}

class ValidExcelResult {
  bool numberValidated;

  ValidExcelResult() : numberValidated = true;
}
