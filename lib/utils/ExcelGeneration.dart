import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<List<int>?> generateLongDistanceScoreExcel(String dbName) async {
  // 生成长距离比赛Excel
  // 读取所有数据表
  Database db = await DatabaseManager.getDatabase(dbName);
  List<Map<String, dynamic>> tables =
      await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  List<String> tableNames = tables.map((row) => row['name'] as String).toList();
  print(tableNames);
  var divisions = [];
  for (var tableName in tableNames) {
    try {
      tableName = tableName.split('_')[0];
    } catch (e) {
      print("表名不符合规范");
      continue;
    }
    if (!divisions.contains(tableName)) {
      divisions.add(tableName);
    }
  }
  divisions.remove('athletes');
  divisions.remove('长距离比赛');
  print(divisions);
  // 生成Excel，生成n个sheet，每一个sheet代表一个组别
  // 生成表头
  var excel = Excel.createExcel();
  List<String> headers = ['编号', '姓名', '代表队', '成绩', '备注'];
  List<String> overviewHeaders = ['编号', '姓名', '代表队', '成绩', '组别', '备注'];
  // 将sheet1重命名为总表
  excel.rename("Sheet1", "总表");
  var overviewSheet = excel["总表"];

  // 设置总表格式
  overviewSheet.merge(
      CellIndex.indexByString('A1'), CellIndex.indexByString('F1'),
      customValue: TextCellValue('桨板长距离赛成绩单'));
  var cell = overviewSheet.cell(CellIndex.indexByString('A1'));
  cell.cellStyle = CellStyle(
    fontSize: 20,
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
  );
  for (int i = 0; i < overviewHeaders.length; i++) {
    overviewSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
      ..value = TextCellValue('${overviewHeaders[i]}')
      ..cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
  }

  overviewSheet.merge(
      CellIndex.indexByString('A2'), CellIndex.indexByString('F3'),
      customValue: TextCellValue('请勿修改此表，数据将由各组别表自动生成'));
  cell = overviewSheet.cell(CellIndex.indexByString('A2'));
  cell.cellStyle = CellStyle(
    fontSize: 14,
    bold: true,
    //设置为红色
    fontColorHex: ExcelColor.red,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  for (var division in divisions) {
    var sheet = excel[division];
    // 设置标题
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'),
        customValue: TextCellValue('${division}长距离成绩表'));
    // 设置合并单元格的样式
    var cell = sheet.cell(CellIndex.indexByString('A1'));
    cell.cellStyle = CellStyle(
      fontSize: 20,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    // 设置B2到E2为header
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
        ..value = TextCellValue('${headers[i]}')
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }
    // 从数据库读取数据
    // 先填此sheet,再填总表的链接数据
    var athletes = await db.rawQuery('''
      SELECT * FROM athletes WHERE division = '$division'
    ''');
    for (int i = 0; i < athletes.length; i++) {
      var athlete = athletes[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 2))
          .value = TextCellValue('${athlete['id']}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2))
          .value = TextCellValue('${athlete['name']}');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2))
          .value = TextCellValue('${athlete['team']}');
      // sheet
      //     .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2))
      //     .value = TextCellValue(''); -todo - 实际代码
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2))
          .value = TextCellValue(randomTimeGenerator());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2))
          .value = TextCellValue('');
      // 将columnIndex: 3, rowIndex: i + 2的数据类型设为字符串
    }
    for (int i = 0; i < athletes.length; i++) {
      var athlete = athletes[i];
      // 填总表的链接数据
      // 从末尾开始填写
      var rowIndex = overviewSheet.maxRows;
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = FormulaCellValue('${division}!A${i + 3}');
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = FormulaCellValue('${division}!B${i + 3}');
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = FormulaCellValue('${division}!C${i + 3}');
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = FormulaCellValue('${division}!D${i + 3}');
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue('$division');
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = FormulaCellValue('${division}!E${i + 3}');
    }
  }
  var fileBytes = excel.encode();
  return fileBytes;
}

String randomTimeGenerator() {
  // 生成一个随机的时间 格式为hh:mm.ss
  Random random = Random();
  int hour = random.nextInt(24);
  int minute = random.nextInt(60);
  int second = random.nextInt(60);
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}.${second.toString().padLeft(2, '0')}';
}
