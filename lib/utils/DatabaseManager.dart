import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static Future<Database> initDatabase() async {
    String path = await getFilePath("storage.db");
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // 创建表
        const sql = '''
        CREATE TABLE competitions_long_distant (
        id INT PRIMARY KEY,
        name VARCHAR(255),
        time DATETIME
);''';
        return db.execute(sql);
      },
      version: 1,
    );
  }
}
