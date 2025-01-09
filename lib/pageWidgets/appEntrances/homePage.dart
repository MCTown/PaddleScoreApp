import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:paddle_score_app/pageWidgets/appEntrances/racesEntrancePage.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../utils/ExcelAnalyzer.dart';


class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContent();
}

class _HomePageContent extends State<HomePageContent> {
  final _formKey = GlobalKey<FormState>();
  final _raceNameController = TextEditingController();
  FilePickerResult? _selectedFile;
  List<int> bytes = [];
  bool _isEventVisible = true;
  bool _isCreateVisible = true;

  get padding => null;

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _selectedFile = result;
          bytes = File(result.paths.first!).readAsBytesSync();
          // print(_selectedFile);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _submitForm() async {
    MyAppState appState3 = Provider.of<MyAppState>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      String raceName = _raceNameController.text;
      //处理Excel文件
      if (_selectedFile != null && raceName.isNotEmpty) {
        if (appState3.races.contains(raceName)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('赛事创建失败'),
                content: const Text('赛事名称已存在,请输入不同的赛事名称'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('确认'),
                  ),
                ],
              );
            },
          );
          return;
        } else {
          showDialog(
            context: context,
            barrierDismissible: false, //点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('正在处理运动员数据,请耐心等待...'),
                  ],
                ),
              );
            },
          );
          await DataHelper.loadExcelFileToAthleteDatabase(raceName, bytes);
          Navigator.of(context).pop();
        }
        appState3.addRace(_raceNameController.text);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('赛事创建成功'),
              content: Text('赛事名称：$raceName'),
              actions: [
                TextButton(
                  onPressed: () {
                    //跳转到赛事页面
                    Navigator.of(context).pop();
                    appState3.setSelectRace(raceName);
                    Navigator.pushNamed(context, '/race/$raceName');
                  },
                  child: const Text('跳转到赛事页面'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确认并返回'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('赛事创建失败'),
                content: raceName.isEmpty
                    ? const Text('赛事名称不能为空')
                    : _selectedFile == null
                        ? const Text('请上传赛事人员名单')
                        : const Text('未知错误'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('确认'),
                  ),
                ],
              );
            });
      }
    }
  }

  void _clearFrom() {
    _formKey.currentState!.reset();
    _raceNameController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  String _lastEvent1 = '尚未创建';
  String _lastEvent2 = '尚未创建';
  String _lastEvent3 = '尚未创建';

  @override
  void initState() {
    super.initState();
    _loadEventsName();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 30),
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
                        '欢迎使用桨板赛事计分系统',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        '近期赛事',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(_isEventVisible
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isEventVisible = expanded;
                        });
                      },
                      initiallyExpanded: true,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/race/${_lastEvent1.toString()}');
                            // 处理点击事件，例如导航到新页面、更新状态等
                          },
                          child: ListTile(
                            title: Text(_lastEvent1),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/race/${_lastEvent1.toString()}');
                          },
                          child: ListTile(
                            title: Text(_lastEvent2),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/race/${_lastEvent1.toString()}');
                          },
                          child: ListTile(
                            title: Text(_lastEvent3),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 30),
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
                          '创建赛事',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        // subtitle: const Text(
                        //   '请上传赛事名称和队员名单',
                        //   style: TextStyle(fontSize: 16),
                        // ),
                        trailing: Icon(_isCreateVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isCreateVisible = expanded;
                          });
                        },
                        initiallyExpanded: true,
                        children: [
                          Container(
                            width: 650,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                // crossAxisAlignment: CrossAxisAlignmen,
                                children: [
                                  TextFormField(
                                    controller: _raceNameController,
                                    decoration: const InputDecoration(
                                        labelText: '赛事名称', hintText: '请输入赛事名称'),
                                    onChanged: (value) {
                                      setState(() {
                                        _raceNameController.text = value;
                                        _raceNameController.selection =
                                            TextSelection.fromPosition(
                                          TextPosition(
                                              offset: _raceNameController
                                                  .text.length),
                                        );
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '请输入赛事名称';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ElevatedButton(
                                      // onPressed:_pickExcelFile,
                                      onPressed: _raceNameController.text == ''
                                          ? null
                                          : () => {
                                                // 跳转到创建赛事
                                                Navigator.pushNamed(
                                                  context,
                                                  '/create',
                                                  arguments: _raceNameController
                                                      .text, // 传递 raceName 参数
                                                )
                                              },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Color(0xFFBBDEFB)),
                                        // padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                        //     EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0)
                                        // ),
                                        shape: WidgetStateProperty.all<
                                                OutlinedBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0))),
                                        shadowColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.black),
                                        elevation: WidgetStateProperty
                                            .resolveWith<double>(
                                                (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.hovered)) {
                                            return 16.0;
                                          }
                                          return 4.0;
                                        }),
                                        overlayColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                      child: const Text('开始创建'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _loadEventsName() async {
    final directory = Directory(await getFilePath(null));
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.db'))
        .toList();
    // 根据修改时间排序（最新的在前面）
    print("123$files");
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // 获取前三个文件名，如果文件数量少于 3 个，则返回所有文件名
    final top3Files = files.take(3).toList();
    List<String> fileNames =
        top3Files.map((file) => file.path.split('/').last).toList();
    setState(() {
      _lastEvent1 = fileNames[0].substring(0, fileNames[0].length - 3);
      ;
      _lastEvent2 = fileNames[1].substring(0, fileNames[1].length - 3);
      ;
      _lastEvent3 = fileNames[2].substring(0, fileNames[2].length - 3);
      ;
    });
  }
}
