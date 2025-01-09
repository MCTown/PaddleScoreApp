import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../universalWidgets/Loading.dart';

bool button1Pressed = false;
bool button2Pressed = false;
class CreateRacePage extends StatefulWidget {
  const CreateRacePage({super.key});

  @override
  _CreateRaceDetailPage createState() => _CreateRaceDetailPage();
}

class _CreateRaceDetailPage extends State<CreateRacePage> {
  String filePath = '';
  @override
  Widget build(BuildContext context) {
    final raceName = ModalRoute
        .of(context)!
        .settings
        .arguments as String? ??
        'No Race Name Provided';
    return Scaffold(
      appBar: AppBar(
        title: Text('创建赛事：$raceName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              print(1); // 点击加号时输出1
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 第一个卡片：下载报名表
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '下载报名表',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮下载最新的报名表。',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // todo实现下载逻辑
                          Loading.startLoading("请稍候", context);
                          try {
                            await Future.delayed(Duration.zero, () async {
                              String? filePath =
                              await FilePicker.platform.saveFile(
                                dialogTitle: '保存参赛名单',
                                fileName: '参赛名单 - $raceName.xlsx',
                              );
                              if (filePath == null) {
                                throw Exception("用户未选择文件");
                              } else {
                                File file = File(filePath);
                                ByteData byteData = await rootBundle
                                    .load("lib/assets/参赛信息.xlsx");
                                Uint8List uint8List = byteData.buffer
                                    .asUint8List(byteData.offsetInBytes,
                                    byteData.lengthInBytes);
                                await file.writeAsBytes(uint8List);
                                print("文件已保存到:$filePath");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('报名表下载完成'),
                                  ),
                                );
                                setState(() {
                                  button1Pressed = true;
                                });
                              }
                            });
                          } catch (e) {
                            print("用户未选择文件");
                            setState(() {
                              button1Pressed = false;
                            });
                          }
                          Loading.stopLoading(context);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('下载报名表'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 第二个卡片：上传报名表
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '上传报名表',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮上传您的填写好的报名表。',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: button1Pressed
                            ? () {
                          // todo 上传逻辑
                          FilePicker.platform.pickFiles().then((result) {
                            if (result != null) {
                              // 处理选中的文件
                              setState(() {
                                filePath = result.paths.first!;
                                button2Pressed = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('报名表上传完成'),
                                ),
                              );
                            } else {
                              setState(() {
                                button2Pressed = false;
                              });
                            }
                          });
                        }
                            : null,
                        icon: const Icon(Icons.upload),
                        label: const Text('上传报名表'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 第三个卡片：确定
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '确定',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮以确认您的操作。',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: button2Pressed
                            ? () async {
                          // 实现确认逻辑
                          Loading.startLoading("正在录入运动员信息，请稍候", context);
                          print(filePath);
                          File xlsxFile = File(filePath!);
                          await DataHelper.loadExcelFileToAthleteDatabase(
                              raceName, xlsxFile.readAsBytesSync());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('运动员已录入'),
                            ),
                          );
                        }
                            : null,
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
