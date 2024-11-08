import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../utils/ExcelGeneration.dart';
import '../page_widgets/DivisionScoreTable.dart';

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
  bool _isCheckAllScore = false;
  Future<List<Map<String, dynamic>>>? _tableDataFuture;
  String? _selectedGroup;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tableDataFuture = getDivisionScore(null);
  }

  Future<List<Map<String, dynamic>>> getDivisionScore(String? division) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/PaddleScoreData/${widget
        .raceEventName}.db';
    print('Database path:$dbPath');
    final database = await openDatabase(dbPath);
    try {
      List<Map<String, dynamic>> data;
      if (division == null) {
        data =
        await database.query('athletes', orderBy: 'long_distant_score ASC');
      } else {
        data = await database.query('athletes', where: 'division = ?',
            whereArgs: [division],
            orderBy: 'long_distant_score ASC');
      }
      return data;
    } catch (e) {
      print('Error getting data from table athletes: $e');
      return [];
    } finally {
      await database.close();
    }
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
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text('加载中...'),
                                ],
                              ),
                            );
                          },
                        );
                        List<
                            int>? excelFileBytes = await generateLongDistanceScoreExcel(
                            widget.raceEventName);
                        if (excelFileBytes == null) {
                          throw Exception("生产Excel文件失败");
                        }
                        Navigator.pop(context);
                        String? filePath = await FilePicker.platform.saveFile(
                          dialogTitle: '保存长距离登记表',
                          fileName: '长距离成绩登记表.xlsx',
                        );
                        if (filePath == null) {
                          throw Exception("用户未选择文件");
                        }
                        File file = File(filePath);
                        await file.writeAsBytes(excelFileBytes);
                        print("文件已保存到:$filePath");
                      },
                      child: const Text(
                        '导出长距离成绩登记表',
                        style: TextStyle(fontSize: 20),)),
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
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
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
                                                  DataCell(Text(row['id']
                                                      .toString())),
                                                  DataCell(Text(row['name']
                                                      .toString())),
                                                  DataCell(Text(row['team']
                                                      .toString())),
                                                  DataCell(Text(row['division']
                                                      .toString())),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: Text('暂无数据'));
                                    }
                                  },
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Card(
                    color: Colors.white,
                    child: Theme(
                      data: ThemeData(
                        dividerColor: Colors.transparent,
                      ),
                      child:
                      ExpansionTile( // 使用 GestureDetector 来触发展开和折叠
                        title: const Text(
                          '查看长距离成绩排名',
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Icon(_isCheckAllScore
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isCheckAllScore = expanded;
                          });
                        },
                        children: [
                          if (_isCheckAllScore)
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 600,
                                  child:
                                  ListTileTheme(
                                      tileColor: Colors.green[50],
                                      child:SingleChildScrollView(
                                        child:
                                        Column(
                                          children: [
                                            ListTile(
                                              title: const Text(
                                                  '各组别总排名'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup = null;
                                                });
                                                print(_selectedGroup);
                                                print('各组别总排名');
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U9组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup = 'U9组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U9组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup = 'U9组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U12组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  'U12组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U12组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  'U12组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U15组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  'U15组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U15组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  'U15组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('U18组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  'U18组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '充气板组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '充气板组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '充气板组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '充气板组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('大师组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '大师组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('大师组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '大师组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '高校甲组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '高校甲组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '高校甲组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '高校甲组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '高校乙组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '高校乙组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '高校乙组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '高校乙组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '卡胡纳组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '卡胡纳组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  '卡胡纳组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '卡胡纳组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('公开组男子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '公开组男子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('公开组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup =
                                                  '公开组女子';
                                                });
                                                print(_selectedGroup);
                                              },
                                            ),

                                          ],
                                        ),
                                      ),
                                  ),
                                ),
                                Expanded(
                                    child: SizedBox(
                                      height: 600,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment:Alignment.topRight,
                                            child:Padding(
                                              padding: const EdgeInsets.only(right: 60),
                                              child: SizedBox(
                                                width:200,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: '搜索组别',
                                                    prefixIcon: const Icon(Icons.search),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(25.0),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.green[50],
                                                  ),
                                                  onChanged: (text) {
                                                    setState(() {
                                                      _selectedGroup = text;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 100),
                                              child: DivisionScoreTable(
                                                  division: _selectedGroup,
                                                  raceEventName: widget.raceEventName),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                )
                              ],
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
