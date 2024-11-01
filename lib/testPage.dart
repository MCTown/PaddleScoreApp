import 'dart:io';
import '/utils/GlobalFunction.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'utils/DatabaseManager.dart';
import 'utils/ExcelAnalysis.dart';

class MatchList extends StatelessWidget {
  const MatchList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Item 1', 'Item 2', 'Item 3'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
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
            title: const Text('Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestNavigator()),
              );
              print(2); // 点击列表项时输出2
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Album'),
            onTap: () {
              print(2); // 点击列表项时输出2
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone'),
            onTap: () {
              print(2); // 点击列表项时输出2
            },
          ),
        ],
      ),
    );
  }
}

class TestNavigator extends StatelessWidget {
  const TestNavigator({super.key});

  Future<void> createFile(String fileName) async {
    print('tryCreateFile');
    final path = await getFilePath(fileName);
    print(path);
    final file = File(path);
    await file.writeAsString("MESSAGE");
  }

  Future<Database> initDatabase(String fileName) async {
    // 获取数据库路径
    String path = await getFilePath(fileName);
    // 打开数据库，如果不存在则创建
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // 创建表
        return db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String event = '2024';
    return FutureBuilder<Database>(
        future: DatabaseManager.getDatabase(event), // 获取数据库的 Future
        builder: (BuildContext context, AsyncSnapshot<Database> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 数据库正在加载时的占位符
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // 处理错误情况
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // 数据库加载成功，使用 snapshot.data
            Database db = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('TestNavigator'),
              ),
              // TODO: Test code
              body: Center(
                  child: Column(children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await loadExcelFileToAthleteDatabase(db);
                  },
                  child: const Text('Pick and Read Excel File'),
                ),
              ])),
            );
          }
        });
  }
}
