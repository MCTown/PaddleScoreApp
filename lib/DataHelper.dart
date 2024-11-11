import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:paddle_score_app/utils/ExcelAnalysis.dart';
import 'package:paddle_score_app/utils/ExcelGeneration.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:paddle_score_app/utils/ScoreAnalysis.dart';
import 'package:sqflite/sqflite.dart';

class DataHelper {
  // 传入报名表的Excel文件
  static Future<void> loadExcelFileToAthleteDatabase(
      String dbName, List<int> xlsxFileBytes) async {
    Database db = await DatabaseManager.getDatabase(dbName);
    var excel = Excel.decodeBytes(xlsxFileBytes);
    // print("可用的table：${excel.tables}");
    var tableSelected = excel.tables.keys.first;
    // print("选中的table：$table_selected");
    var table = excel.tables[tableSelected]!;
    // print("表格的行数：${table.maxRows}");
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
      // print("第$i行数据：${row[0]?.value ?? ''} ${row[1]?.value ?? ''} ${row[2]?.value ?? ''} ${row[3]?.value ?? ''}");
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
      // 先处理长距离的表
      await db.insert("长距离比赛", {
        "id": row[1]!.value.toString(),
        "name": row[2]!.value.toString(),
        "time": "0"
      });
    }
    await initScoreTable(db);
    return;
  }

  // 生成长距离比赛成绩表
  static Future<List<int>?> generateLongDistanceScoreExcel(
      String dbName) async {
    // 生成长距离比赛Excel
    // 读取所有数据表
    Database db = await DatabaseManager.getDatabase(dbName);
    List<Map<String, dynamic>> tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    List<String> tableNames =
        tables.map((row) => row['name'] as String).toList();
    print(tableNames);
    var divisions = await getDivisions(dbName);
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
      overviewSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(overviewHeaders[i])
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
          customValue: TextCellValue('$division长距离成绩表'));
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
          ..value = TextCellValue(headers[i])
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
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = FormulaCellValue('$division!A${i + 3}');
        overviewSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = FormulaCellValue('$division!B${i + 3}');
        overviewSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = FormulaCellValue('$division!C${i + 3}');
        overviewSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = FormulaCellValue('$division!D${i + 3}');
        overviewSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(division);
        overviewSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = FormulaCellValue('$division!E${i + 3}');
      }
    }
    var fileBytes = excel.encode();
    return fileBytes;
  }

  // 导入长距离比赛成绩
  static Future<void> importLongDistanceScore(
      String dbName, List<int> fileBinary) async {
    String tableName = "长距离比赛";
    Database db = await DatabaseManager.getDatabase(dbName);
    var excel = Excel.decodeBytes(fileBinary);
    Map<String, Sheet> sheets = excel.sheets;
    // 录入数据到长距离比赛时间
    var divisions = await getDivisions(dbName);
    // 遍历所有sheet
    // print(divisions);
    for (var division in divisions) {
      var sheet = sheets[division];
      if (sheet == null) {
        throw Exception("表格中没有$division");
      } else {
        //todo reconsider
        // 要实现的是从表格里读取所有运动员的长距离数据，并进行分组
        // 分别录入到长距离成绩表，与所有初赛成绩表中
        // 读取成绩并打印 读取格式为{编号:时间}
        Map<String, String> scores = {};
        var maxRows = sheet.maxRows;
        for (int i = 2; i < maxRows; i++) {
          var id = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
              .value
              .toString();
          var time = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i))
              .value
              .toString();
          // 录入长距离数据库
          db.update(tableName, {"time": time},
              where: "id = ?", whereArgs: [id]);
          scores[id] = timeAnalysis(time);
          // 录入到初赛数据库
          var tables = await DatabaseManager.getTableNames(db);
          for (var t in ['${division}_初赛_趴板', '${division}_初赛_竞速']) {
            if (!tables.contains(t)) {
              continue;
            }
            db.update(t, {"long_distant_time": time},
                where: "id = ?", whereArgs: [id]);
          }
        }
        // 将id按时间排序
        scores = Map.fromEntries(scores.entries.toList()
          ..sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value))));
        var processedGroup = getGroup(scores);
        // processedGroup的key为id，value为组别，将组别录入数据库
        var tables = await DatabaseManager.getTableNames(db);
        var tablesName = ['${division}_初赛_趴板', '${division}_初赛_竞速'];
        for (var tableName in tablesName) {
          if (!tables.contains(tableName)) {
            continue;
          }
          processedGroup.forEach((key, value) {
            db.update(tableName, {"_group": value},
                where: "id = ?", whereArgs: [key]);
          });
        }
      }
    }
    print("All good");
  }

  // 生成趴板和竞速的Excel
  // 四个参数分别为组别、比赛进度、项目、水域类型、数据库名
  static Future<List<int>?> generateGenericExcel(
      String division, CType c, SType s, WType w, String dbName) async {
    print('生成$division${cTypeTranslate(c)}${sTypeTranslate(s)}的Excel');
    var excel = Excel.createExcel();
    var tableName = "${division}_${sTypeTranslate(s)}_${cTypeTranslate(c)}";
    Database db = await DatabaseManager.getDatabase(dbName);
    var a = await db.query(tableName, columns: ['id']);
    var athletesNum = a.length;
    // 生成Excel
    int groupNum = (athletesNum / 16).ceil();
    if (groupNum == 0) {
      throw Exception("该比赛尚未进行！");
    }
    for (var i = 0; i < groupNum; i++) {
      // 查询_group == i的运动员
      print('正在录入第${i + 1}组');
      var athletes = await db.query(tableName,
          columns: ['id', 'name', 'long_distant_time'],
          where: '_group = ?',
          whereArgs: [i + 1]);
      print('查询$tableName,查询到的运动员：$athletes');
      List<String> headers = ['编号', '姓名', '成绩', '长距离比赛成绩', '出发赛道', '备注'];
      var sheet =
          excel['$division${cTypeTranslate(c)}${sTypeTranslate(s)}${i + 1}'];
      // 设置标题
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'),
          customValue: TextCellValue(
              '$division${cTypeTranslate(c)}${sTypeTranslate(s)}${i + 1}'));
      // 添加header
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          ..value = TextCellValue(headers[i])
          ..cellStyle = CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
          );
      }
      // 录入运动员
      var index = 2;
      for (var athlete in athletes) {
        print('正在录入${athlete['name']}');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index))
            .value = TextCellValue('${athlete['id']}');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index))
            .value = TextCellValue('${athlete['name']}');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: index))
            .value = TextCellValue('');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: index))
            .value = TextCellValue('${athlete['long_distant_time']}');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: index))
            .value = TextCellValue('');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: index))
            .value = TextCellValue('');
        ++index;
      }
      // 删除sheet1
      excel.delete('Sheet1');
    }
    return excel.encode();
  }
}
