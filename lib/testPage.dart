import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:paddle_score_app/utils/ExcelGeneration.dart';
import 'package:paddle_score_app/utils/ScoreAnalysis.dart';

import '/utils/GlobalFunction.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'utils/DatabaseManager.dart';
import 'utils/ExcelAnalysis.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Item 1', 'Item 2', 'Item 3'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('标题'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              print(1); // 点击加号时输出1
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('初始化数据库'),
            onTap: () async {
              String dbName = "athlete";
              File xlsxFile = File("/home/apricityx/Desktop/参赛信息-_汉丰湖.xlsx");

              // 显示加载对话框
              showDialog(
                context: context,
                barrierDismissible: false, // 点击外部不可关闭
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("加载中..."),
                      ],
                    ),
                  );
                },
              );

              // 执行加载操作
              try {
                await loadExcelFileToAthleteDatabase(
                    dbName, xlsxFile.readAsBytesSync());
              } catch (e) {
                print(e);
              }

              // 关闭对话框
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('下载成绩表'),
            onTap: () async {
              String dbName = "athlete";
              // File xlsxFile = File("/run/media/apricityx/Data2/Resources/参赛信息-_汉丰湖.xlsx");
              // 显示加载对话框
              showDialog(
                context: context,
                barrierDismissible: false, // 点击外部不可关闭
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("加载中..."),
                      ],
                    ),
                  );
                },
              );
              List<int>? excelFileBytes =
                  await generateLongDistanceScoreExcel(dbName);
              if (excelFileBytes == null) {
                throw Exception("生成 Excel 文件失败");
              }
              // String? filePath = await FilePicker.platform.saveFile(
              //   dialogTitle: '保存 Excel 文件',
              //   fileName: '长距离成绩单.xlsx',
              // );
              var filePath =
                  "/run/media/apricityx/Data1/Desktop/长距离成绩单.xlsx"; // -todo
              // 创建文件并写入字节数据
              File file = File(filePath);
              await file.writeAsBytes(excelFileBytes);

              print('文件已保存到: $filePath');
              // 关闭对话框
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('导入长距离成绩'),
            onTap: () async {
              File exampleFile = File("/home/apricityx/Desktop/长距离成绩单.xlsx");
              await importLongDistanceScore(
                  'athlete', exampleFile.readAsBytesSync());
            },
          ),
          ListTile(
            leading: const Icon(Icons.abc),
            title: const Text('导入通用成绩表'),
            onTap: () async {
              String dbName = "athlete";
              String path = "/home/apricityx/Desktop/U18组男子通用测试.xlsx";
              // 显示加载对话框
              showDialog(
                context: context,
                barrierDismissible: false, // 点击外部不可关闭
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("加载中..."),
                      ],
                    ),
                  );
                },
              );
              try {
                List<int>? exampleFile = await generateGenericExcel("U18组男子", CType.pronePaddle,
                    SType.firstRound, WType.static, dbName);
                File file = File(path);
                await file.writeAsBytes(exampleFile!);

                print('文件已保存到: $path');
              } catch (e) {
                print(e);
              }

              // 关闭对话框
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
