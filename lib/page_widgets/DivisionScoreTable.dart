import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../page_widgets/longDistanceRace_page.dart';

class DivisionScoreTable extends StatefulWidget {
  final String? division;
  final String raceEventName;
  const DivisionScoreTable({Key? key, required this.division, required this.raceEventName}) : super(key: key);

  @override
  _DivisionScoreTableState createState() => _DivisionScoreTableState();
}

class _DivisionScoreTableState extends State<DivisionScoreTable> {
  Future<List<Map<String,dynamic>>> getDivisionScore(String? division)async{
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/PaddleScoreData/${widget.raceEventName}.db';
    print('Database path:$dbPath');
    final database = await openDatabase(dbPath);
    try{
      List<Map<String,dynamic>> data;
      if(division == null){
        data = await database.query('athletes',orderBy: 'long_distant_score ASC');
      }else{
        data = await database.query('athletes',where:'division = ?',whereArgs: [division],orderBy: 'long_distant_score ASC');
      }
      return data;
    }catch(e){
      print('Error getting data from table athletes: $e');
      return[];
    }finally{
      await database.close();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container( // 使用 Container 作为根组件
      height: 500, // 设置固定高度
      width: 800, // 设置固定宽度
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getDivisionScore(widget.division),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('错误: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            return SingleChildScrollView( // 使用 SingleChildScrollView 使表格可滚动
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('排名')),
                  DataColumn(label: Text('编号')),
                  DataColumn(label: Text('姓名')),
                  DataColumn(label: Text('单位')),
                  DataColumn(label: Text('成绩')),
                ],
                rows: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final score = row['long_distant_score'];
                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(row['id'].toString())),
                      DataCell(Text(row['name'].toString())),
                      DataCell(Text(row['team'].toString())),
                      DataCell(Text(score != 0 ? score.toString() : '暂无成绩')),
                    ],
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: Text('暂无数据'));
          }
        },
      ),
    );
  }
}