import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../widgetHelper.dart';
import 'dart:typed_data';

import 'ScoreTableWidget.dart';


class LongDistanceRacePage extends StatefulWidget {
  final String raceBar;
  final String raceEventName;

  const LongDistanceRacePage(
      {super.key, required this.raceBar, required this.raceEventName});

  @override
  State<LongDistanceRacePage> createState() => _LongDistanceRacePageState();
}

class _LongDistanceRacePageState extends State<LongDistanceRacePage> {
  bool _isTableVisible = false;
  bool _isCheckAllScore = false;
  Future<List<Map<String, dynamic>>>? _tableDataFuture;
  String? _selectedGroup;
  List<String> raceTypeOptions = ['所有', '竞速赛', '趴板赛'];
  List<String> divisionOptions = [
    '所有',
    'U9组',
    'U12组',
    'U15组',
    'U18组',
    '充气板组',
    '大师组',
    '高校甲组',
    '高校乙组',
    '卡胡纳组',
    '公开组'
  ];
  List<String> genderOptions = ['所有', '男子', '女子'];
  String? _selectedRaceType = '';
  String? _selectedDivision = '';
  String? _selectedGender = '';
  String raceType = '赛事类型';
  String division = '赛事组别';
  String gender = '性别';

  @override
  void initState() {
    super.initState();
    _tableDataFuture = getDivisionScore(null);
    _selectedRaceType = raceTypeOptions[0];
    _selectedDivision = divisionOptions[0];
    _selectedGender = genderOptions[0];
  }

  Future<List<Map<String, dynamic>>> getDivisionScore(String? division) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath =
        '${directory.path}/PaddleScoreData/${widget.raceEventName}.db';
    print('Database path:$dbPath');
    final database = await openDatabase(dbPath);
    try {
      List<Map<String, dynamic>> data;
      if (division == null) {
        data =
        await database.query('athletes', orderBy: 'long_distance_score ASC');
      } else {
        data = await database.query('athletes',
            where: 'division = ?',
            whereArgs: [division],
            orderBy: 'long_distance_score ASC');
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
    Widget raceTypeDropdown = WidgetHelper.createDropdownButton(
        raceType, raceTypeOptions, _selectedRaceType!, (String? newValue) {
      setState(() {
        _selectedRaceType = newValue;
      });
    });
    Widget divisionTypeDropdown = WidgetHelper.createDropdownButton(
        division, divisionOptions, _selectedDivision!, (String? newValue) {
      setState(() {
        _selectedDivision = newValue;
      });
    });
    Widget genderTypeDropdown = WidgetHelper.createDropdownButton(
        gender, genderOptions, _selectedGender!, (String? newValue) {
      setState(() {
        _selectedGender = newValue;
      });
    });
    Widget exportButton = ElevatedButton(
        onPressed: () async {
          SType s = SType.firstRound;
          if (_selectedDivision == '所有' || _selectedRaceType == '所有' ||
              _selectedGender == '所有') {
            List<ArchiveFile> archiveFiles = [];
            for (var div in divisionOptions.where((element) =>
            element != '所有')) {
              for (var raceType in raceTypeOptions.where((element) =>
              element != '所有')) {
                for (var gender in genderOptions.where((element) =>
                element != '所有')) {
                  CType c = raceType == '竞速赛' ?
                  CType.sprint : (_selectedDivision!.startsWith('U') ?
                  CType.pronePaddle : CType.sprint);
                  int athleteCount = await getAthleteCountByDivision(
                      widget.raceEventName, div + gender);
                  if (athleteCount <= 16) {
                    s = SType.finals;
                  } else {
                    s = SType.firstRound;
                  }
                  String raceProgress = s == SType.firstRound ? '初赛' : '决赛';
                  List<int>? fileBinary = await DataHelper.generateGenericExcel(
                      (div + gender).toString(), c, s,
                      widget.raceEventName);
                  if (fileBinary != null) {
                    //将文件二进制码添加到 archiveFiles 列表中
                    archiveFiles.add(ArchiveFile(
                        '${div + gender}_$raceProgress分组名单.xlsx',
                        fileBinary.length, fileBinary));
                  }
                }
              }
            }
            //创建一个 Archive 对象将archiveFiles列表中的文件打包成压缩包
            final archive = Archive();
            for (var file in archiveFiles) {
              archive.addFile(file); // 使用 addFile() 来添加文件
            }
            final bytes = ZipEncoder().encode(archive) as Uint8List;
            //将压缩包保存到手机本地
            String? filePath = await FilePicker.platform.saveFile(
                dialogTitle: '保存短距离赛事分组汇总表',
                fileName: '短距离赛事分组汇总表.zip');
            if (filePath != null) {
              File file = File(filePath);
              await file.writeAsBytes(bytes as List<int>);
              print("文件已保存到:$filePath");
            }
          } else {
            String divisionName = _selectedDivision! + _selectedGender!;
            CType c = _selectedRaceType == '竞速赛' ?
            CType.sprint : (_selectedDivision!.startsWith('U') ?
            CType.pronePaddle : CType.sprint);
            int athleteCount = await getAthleteCountByDivision(
                widget.raceEventName, divisionName);
            if (athleteCount <= 16) {
              s = SType.finals;
            } else {
              s = SType.firstRound;
            }
            String raceProgress = s == SType.firstRound ? '初赛' : '决赛';
            List<int>? fileBinary = await DataHelper.generateGenericExcel(
                divisionName, c, s, widget.raceEventName);
            String? filePath = await FilePicker.platform.saveFile(
              dialogTitle: '保存$divisionName分组表',
              fileName: '${divisionName}_${raceProgress}分组名单.xlsx',
            );
            if (filePath != null) {
              File file = File(filePath);
              await file.writeAsBytes(fileBinary!);
              print('文件已保存到:$filePath');
            }
          }
        }, child: const Text("导出分组名单"));
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
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue[100]),
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        textStyle: WidgetStateProperty.all(TextStyle(fontSize: 20)),
                        padding:WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(horizontal: 20,vertical:15)
                        ),
                        shape:WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                        ),
                        elevation: WidgetStateProperty.resolveWith<double>((Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return 16.0;
                          }
                          return 8.0;
                        }),
                      ),
                      onPressed: () async {
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (BuildContext context) {
                        //     return const AlertDialog(
                        //       content: Row(
                        //         children: [
                        //           CircularProgressIndicator(),
                        //           SizedBox(width: 20),
                        //           Text('加载中...'),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // );
                        print(widget.raceEventName);
                        List<int>? excelFileBytes =
                        await DataHelper.generateLongDistanceScoreExcel(
                            widget.raceEventName);
                        if (excelFileBytes == null) {
                          throw Exception("生成Excel文件失败");
                        }
                        // Navigator.pop(context);
                        Future.delayed(Duration.zero, () async {
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
                        });
                      },
                      child: const Text(
                        '导出长距离成绩登记表',
                        style: TextStyle(fontSize: 20),
                      )),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue[100]),
                      foregroundColor: WidgetStateProperty.all(Colors.black),
                      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 20)),
                      padding:WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(horizontal: 20,vertical:15)
                      ),
                      shape:WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      elevation: WidgetStateProperty.resolveWith<double>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.hovered)) {
                          return 16.0;
                        }
                        return 8.0;
                      }),
                    ),
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
                        List<int> fileBinary =
                        File(result.paths.first!).readAsBytesSync();
                        DataHelper.importLongDistanceScore(
                            widget.raceEventName, fileBinary);
                      }
                    },
                    child: _selectedFile != null
                        ? Text('已导入成绩: $_selectedFile',
                        style: const TextStyle(fontSize: 18))
                        : const Text(
                      '导入长距离成绩',
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
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "导出短距离初赛分组名单", style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 30,),
                            Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  raceTypeDropdown,
                                  divisionTypeDropdown,
                                  genderTypeDropdown,
                                  exportButton,
                                ]),
                            const SizedBox(height: 20,),
                          ],
                        ))),
              ),
              const SizedBox(height: 20),
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                            columns: const [
                                              DataColumn(label: Text('编号')),
                                              DataColumn(label: Text('姓名')),
                                              DataColumn(label: Text('单位')),
                                              DataColumn(label: Text('组别')),
                                            ],
                                            rows: _tableData.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(
                                                      row['id'].toString())),
                                                  DataCell(Text(
                                                      row['name'].toString())),
                                                  DataCell(Text(
                                                      row['team'].toString())),
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
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Card(
                    color: Colors.white,
                    child: Theme(
                      data: ThemeData(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        // 使用 GestureDetector 来触发展开和折叠
                        title: const Text(
                          '查看长距离成绩排名',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                  child: ListTileTheme(
                                    tileColor: Colors.grey[100],
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: const Text('各组别总排名'),
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
                                                _selectedGroup = 'U12组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('U12组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = 'U12组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('U15组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = 'U15组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('U15组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = 'U15组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('U18组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = 'U18组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                              title: const Text('U18组女子'),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGroup = 'U18组女子';
                                                });
                                                print(_selectedGroup);
                                              }),
                                          ListTile(
                                            title: const Text('充气板组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '充气板组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('充气板组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '充气板组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('大师组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '大师组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('大师组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '大师组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('高校甲组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '高校甲组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('高校甲组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '高校甲组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('高校乙组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '高校乙组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('高校乙组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '高校乙组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('卡胡纳组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '卡胡纳组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('卡胡纳组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '卡胡纳组女子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('公开组男子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '公开组男子';
                                              });
                                              print(_selectedGroup);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('公开组女子'),
                                            onTap: () {
                                              setState(() {
                                                _selectedGroup = '公开组女子';
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
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(right: 60),
                                              child: SizedBox(
                                                width: 200,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: '搜索组别',
                                                    prefixIcon:
                                                    const Icon(Icons.search),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                      borderSide: BorderSide
                                                          .none,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors
                                                        .purple[50],
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
                                              padding:
                                              const EdgeInsets.only(left: 100),
                                              child: DivisionScoreTable(
                                                  division: _selectedGroup,
                                                  raceEventName:
                                                  widget.raceEventName),
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
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