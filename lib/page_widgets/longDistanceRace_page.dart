import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LongDistanceRacePage extends StatefulWidget {
  final String raceBar;
  final String raceEventName;

  const LongDistanceRacePage(
      {super.key, required this.raceBar, required this.raceEventName});

  @override
  State<LongDistanceRacePage> createState() => _LongDistanceRacePageState();
}

class _LongDistanceRacePageState extends State<LongDistanceRacePage> {
  // Future<List<Map<String,dynamic>>> ? _tableData;
  bool _isTableVisible = false;
  Future<List<Map<String, dynamic>>>? _tableDataFuture;

  @override
  void initState() {
    super.initState();
    _tableDataFuture = _loadData();
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath =
        '${directory.path}/PaddleScoreData/${widget.raceEventName}.db';
    final database = await openDatabase(dbPath);
    return database
        .query('athletes', columns: ['id', 'name', 'team', 'division']);
  }

  String? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceBar),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['xlsx'],
                        withData: true,
                        allowMultiple: false,
                      );
                      if (result != null) {
                        setState(() {
                          final file = result.files.single;
                          setState(() {
                            _selectedFile = file.name;
                          });
                        });
                      }
                    },
                    child: const Text(
                      '导入成绩',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  if (_selectedFile != null) Text('已选择文件：$_selectedFile'),
                  ElevatedButton(
                    onPressed: () {
                      print('点击生成200米趴板划水赛初赛分组名单');
                    },
                    child: const Text(
                      '生成200米趴板划水赛初赛分组名单',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('点击了生成200米竟赛初赛分组名单');
                    },
                    child: const Text(
                      '生成200米竟赛初赛分组名单',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Card(
                      color: Colors.white,
                      child: Theme(
                        data: ThemeData(
                            dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: const Text(
                            '查看参赛运动员名单',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Icon(_isTableVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              _isTableVisible = expanded;
                            });
                          },
                          children: [
                            if (_isTableVisible)
                              RepaintBoundary(
                                child: SizedBox(
                                  height: 500,
                                  width: 800,
                                  child:
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _tableDataFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Text('Error:${snapshot.error}');
                                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                        final _tableData = snapshot.data!;
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              columns:
                                                  const [
                                                    DataColumn(label: Text('编号')),
                                                    DataColumn(label: Text('姓名')),
                                                    DataColumn(label: Text('单位')),
                                                    DataColumn(label: Text('组别')),
                                                  ],
                                              rows: _tableData.map((row) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(Text(row['id'].toString())),
                                                    DataCell(Text(row['name'].toString())),
                                                    DataCell(Text(row['team'].toString())),
                                                    DataCell(Text(row['division'].toString())),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(child: Text('暂无数据'));
                                      }
                                    },
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
