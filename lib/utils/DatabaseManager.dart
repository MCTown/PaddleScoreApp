import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static Future<Database> getDatabase(String event) async {
    String path = await getFilePath("$event.db");
    // 如若数据库存在则删除
    // await deleteDatabase(path);
    // delete test code -todo
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        print("数据库不存在，创建数据库：$path");
        await initAthleteTable(db);
      },
      version: 1,
    );
  }

  static Future<void> initAthleteTable(Database db) async {
    const sql = '''
    CREATE TABLE athletes (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    team VARCHAR(255),
    division VARCHAR(255),
    long_distant_score INT,
    prone_paddle_score INT,
    sprint_score INT
);
    ''';
    await db.execute(sql);
    await initLongDistantTable(db);
  }

  // 插入长距离的具体实现在读取Excel的时已经完成
  static Future<void> initLongDistantTable(Database db) async {
    await db.execute('''
        CREATE TABLE '长距离比赛' (
          id INT PRIMARY KEY,
          name VARCHAR(255),
          time VARCHAR(255)
);
      ''');
  }

  // 获取所有数据表的表名
  static Future<List<String>> getTableNames(Database db) {
    return db
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'")
        .then((tables) => tables.map((row) => row['name'] as String).toList());
  }
}
