import 'dart:ffi';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseManager.dart';

// Future<void> readExcelFile() async {
//   // Use FilePicker to select the .xlsx file
//   var db = await DatabaseManager.getDatabase("$event");
//   print("object loaded");
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['xlsx'],
//     withData: true,
//     allowMultiple: false, // Ensure single file selection
//   );
//   // print(result);
//   if (result != null) {
//     print("文件已选择${result.paths.first as String}");
//     var bytes = File(result.paths.first as String).readAsBytesSync();
//     var excel = Excel.decodeBytes(bytes);
//     print("可用的table：${excel.tables}");
//     var table_selected = excel.tables.keys.first;
//     print("选中的table：$table_selected");
//     var table = excel.tables[table_selected]!;
//     print("表格的行数：${table.maxRows}");
//   } else {
//     print("文件未选择");
//   }
// }

// 传入数据库对象，让用户选择一个excel文件，然后将excel文件中的数据导入到数据库中
Future<void> loadExcelFileToAthleteDatabase(Database db) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
    withData: true,
    allowMultiple: false, // Ensure single file selection
  );
  if (result != null) {
    print("文件已选择${result.paths.first as String}");
    var bytes = File(result.paths.first as String).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
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
      print(
          "第$i行数据：${row[0]?.value ?? ''} ${row[1]?.value ?? ''} ${row[2]?.value ?? ''} ${row[3]?.value ?? ''}");
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
      print("运动员录入完成");
    }
  } else {
    print("用户未选择文件，退出");
    return;
  }
}
