import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:paddle_score_app/main.dart';
import 'package:paddle_score_app/utils/CreateRaceExcelChecker.dart';
import 'package:paddle_score_app/utils/SettingService.dart';

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
  List<String> divisions = [];
  int athleteNum = 0;
  ValidExcelResult isExcelValid = ValidExcelResult();

  @override
  Widget build(BuildContext context) {
    if (SettingService.settings['isDebugMode']) {
      button1Pressed = true;
      button2Pressed = true;
    }
    final raceName = ModalRoute.of(context)!.settings.arguments as String? ??
        'No Race Name Provided';
    return Scaffold(
      appBar: AppBar(
        title: Text('创建赛事：$raceName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 说明文字 居左 有标题和正文
            /// todo: 优化文字说明
            // 第一个卡片：下载报名表
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '第一步： 下载报名表',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮下载最新的报名表，下载好报名表后，请将运动员的信息填写进报名表中',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Loading.startLoading("请稍候", context);
                          try {
                            await Future.delayed(Duration.zero, () async {
                              String? filePath =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: '保存参赛名单',
                                fileName: '参赛名单 - $raceName.xlsx',
                              );
                              if (filePath == null) {
                                throw Exception("用户未保存文件");
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
                            print("用户未保存文件");
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
                      '第二步：上传报名表',
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
                                FilePicker.platform
                                    .pickFiles()
                                    .then((result) async {
                                  if (result != null) {
                                    // 处理选中的文件
                                    print(result.files.first.name);
                                    var tempDivision =
                                        await CreateRaceExcelChecker
                                            .getDivisions(
                                                File(result.paths.first!)
                                                    .readAsBytesSync());
                                    int tempAthleteNum =
                                        await CreateRaceExcelChecker
                                            .getAthleteCount(
                                                File(result.paths.first!)
                                                    .readAsBytesSync());
                                    ValidExcelResult tempIsExcelValid =
                                        CreateRaceExcelChecker.validExcel(
                                            File(result.paths.first!)
                                                .readAsBytesSync());
                                    setState(() {
                                      filePath = result.paths.first!;
                                      button2Pressed = true;
                                      divisions = tempDivision;
                                      athleteNum = tempAthleteNum;
                                      isExcelValid = tempIsExcelValid;
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
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '第三步：确定',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请点击确认按钮来创建一个新的比赛',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),

                    /// 确认信息
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: button2Pressed
                            ? () async {
                                /// 弹出弹窗让用户确认信息
                                var isConfirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('确认信息'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Card(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 16),
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.info,
                                                      color: Colors.green),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "请确认以下解析得出的信息是否正确，如若有误请检查你的报名表，删除不需要分析的人员和组别，修正后再次上传",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Card(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, // 让标题左对齐
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom:
                                                              8), // 标题和内容之间的间距
                                                      child: Text(
                                                        '基本信息',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            "赛事名称：$raceName\n报名表路径：$filePath\n参赛总人数：$athleteNum人",
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start, // 让标题左对齐
                                                children: [
                                                  // 标题部分
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom:
                                                            8), // 标题和内容之间的间距
                                                    child: Text(
                                                      '参赛组别',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  // 内容部分（原来的Row和Wrap）
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 8.0, // 水平间距
                                                          runSpacing:
                                                              4.0, // 纵向间距
                                                          children: divisions
                                                              .map((division) {
                                                            return Chip(
                                                              label: Text(
                                                                  division),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Card(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, // 让标题左对齐
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom:
                                                              8), // 标题和内容之间的间距
                                                      child: Text(
                                                        '错误检查',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                            child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              isExcelValid
                                                                      .numberValidated
                                                                  ? "✅ 报名表中编号无误"
                                                                  : "⚠ 报名表中有错误的编号，这可能是因为单元格格式错误或是有多余的空格，请检查",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: isExcelValid
                                                                          .numberValidated
                                                                      ? Colors
                                                                          .black87
                                                                      : Colors
                                                                          .red,
                                                                  fontWeight: isExcelValid
                                                                          .numberValidated
                                                                      ? FontWeight
                                                                          .normal
                                                                      : FontWeight
                                                                          .bold),
                                                            ),
                                                            // Text(
                                                            //   isExcelValid
                                                            //       .numberValidated
                                                            //       ? "报名表中有错误的编号，这可能是因为单元格为字符格式或是有多余的空格，请检查"
                                                            //       : "✅报名表中编号无误",
                                                            //   style: const TextStyle(
                                                            //       fontSize: 16,
                                                            //       color: Colors
                                                            //           .black87),
                                                            // ),
                                                          ],
                                                        )),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('确定'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('取消'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (isConfirmed == null || !isConfirmed) {
                                  return;
                                }
                                Loading.startLoading("正在录入运动员信息，请稍候", context);
                                print(filePath);
                                File xlsxFile = File(filePath);
                                try {
                                  await DataHelper
                                      .loadExcelFileToAthleteDatabase(
                                          raceName, xlsxFile.readAsBytesSync());
                                  Loading.stopLoading(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('运动员已录入'),
                                    ),
                                  );

                                  /// 返回首页并刷新
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const MyHomePage()),
                                        (route) => false,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('新比赛已创建'),
                                    ),
                                  );
                                } catch (e) {
                                  Loading.stopLoading(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('录入失败，请检查报名表无误后重试'),
                                    ),
                                  );
                                }
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
