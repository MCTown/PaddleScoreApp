import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static Future<Database> getDatabase(String event) async {
    String path = await getFilePath("$event.db");
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
  }
}
