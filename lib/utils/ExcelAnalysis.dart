import 'dart:ffi';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

Future<void> readExcelFile() async {
  // Use FilePicker to select the .xlsx file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
    withData: true,
    allowMultiple: false, // Ensure single file selection
  );
  // print(result);
  if (result != null) {
    print("文件已选择${result.paths.first as String}");
    var bytes = File(result.paths.first as String).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    print("可用的table：${excel.tables}");
    var table_selected = excel.tables.keys.first;
    print("选中的table：$table_selected");
    var table = excel.tables[table_selected]!;
    print("表格的行数：${table.maxRows}");
  } else {
    print("文件未选择");
  }
  //   // Load the selected file
  //   var fileBytes = result.files.first.bytes;
  //   var excel = Excel.decodeBytes(fileBytes!);

  // Check if "Sheet1" exists
  // if (excel.tables.containsKey('Sheet1')) {
  //   print('Data from Sheet1:');
  //   // Get data from "Sheet1"
  //   for (var row in excel.tables['Sheet1']!.rows) {
  //     // Print each cell's value in the row
  //     print(row.map((cell) => cell?.value).toList());
  //   }
  // } else {
  //   print('Sheet1 does not exist.');
  // }
  // }
}
