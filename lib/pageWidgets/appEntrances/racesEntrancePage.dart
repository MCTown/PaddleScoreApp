import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:paddle_score_app/pageWidgets/universalWidgets/Loading.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';

// import 'package:paddle_score_app/page_widgets/shortDistancePage.dart';
import 'package:provider/provider.dart';

import '../longDistanceRace/longDistancePage.dart';
import '../shortDistanceRace/shortDistancePage.dart';

enum RaceType {
  longRace,
  shortRace1,
  shortRace2,
  teamRace,
  personalScore,
}

class RaceCardState extends ChangeNotifier {
  String raceEventName = '';
}

class RaceCard extends StatefulWidget {
  final RaceType rt;

  const RaceCard({super.key, required this.rt});

  @override
  State<RaceCard> createState() => _RaceCard();
}

class _RaceCard extends State<RaceCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    RaceType rt = widget.rt;
    String title;
    switch (rt) {
      case RaceType.longRace:
        title = '6000米长距离赛（青少年3000米）';
        break;
      case RaceType.shortRace1:
        title = '200米趴板划水赛（仅限青少年）';
        break;
      case RaceType.shortRace2:
        title = '200米竞速赛';
        break;
      case RaceType.teamRace:
        title = '团体竞赛';
        break;
      case RaceType.personalScore:
        title = '个人积分';
        break;
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var raceCardState_ = context.watch<RaceCardState>();
      String raceName = raceCardState_.raceEventName;
      double cardWidth = constraints.maxWidth * 0.7;
      // todo
      return Placeholder();
    });
  }
}

class RacePage extends StatelessWidget {
  final String raceName;

  const RacePage({super.key, required this.raceName});

  @override
  Widget build(BuildContext context) {
    final raceCardState = context.watch<RaceCardState>();
    raceCardState.raceEventName = raceName;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(raceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: ListTile(
                tileColor: Theme.of(context).canvasColor,
                title: Text("6000米长距离赛（青少年3000米）"),
                subtitle: Text("点击进入"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final raceBar = '$raceName/6000米长距离赛（青少年3000米）';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LongDistanceRacePage(
                          raceBar: raceBar, raceEventName: raceName),
                    ),
                  );
                },
              ),
            ),
            RaceNameCard(
              title: '200米趴板划水赛（仅限青少年）',
              raceName: raceName,
              subtitle: "点击进入",
            ),
            RaceNameCard(
              title: '200米竞速赛',
              raceName: raceName,
              subtitle: "点击进入",
            ),
            Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: ListTile(
                tileColor: Theme.of(context).canvasColor,
                title: Text("个人积分导出"),
                subtitle: Text("点击下载"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  var choice = await showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("请选择导出类型"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            // 这里添加了空的Text widget
                            onPressed: () => Navigator.pop(context, "A"),
                            child: const Text('按组别导出'), // 补全了 child 属性
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, "B"),
                            child: const Text('按代表队导出'),
                          ),
                        ],
                      );
                    },
                  );
                  Loading.startLoading("导出中", context);
                  List<int> finalScoreBinary;
                  if (choice == 'A') {
                    finalScoreBinary = await DataHelper.exportFinalScore(
                        raceName, ExportType.asDivision);
                  } else if (choice == 'B') {
                    finalScoreBinary = await DataHelper.exportFinalScore(
                        raceName, ExportType.asTeam);
                  } else {
                    Loading.stopLoading(context);
                    return;
                  }
                  try{
                    await Future.delayed(Duration.zero, () async {
                      String? filePath = await FilePicker.platform.saveFile(
                        dialogTitle: '保存个人积分',
                        fileName: '个人积分 - $raceName.xlsx',
                      );
                      if (filePath == null) {
                        throw Exception("用户未选择文件");
                      } else {
                        File file = File(filePath);

                        print("!!TEST!!$choice");

                        await file.writeAsBytes(finalScoreBinary);
                        print("文件已保存到:$filePath");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('积分表下载完成')),
                        );
                        Loading.stopLoading(context);
                      }
                    });
                  }catch(e){
                    Loading.stopLoading(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RaceNameCard extends StatelessWidget {
  final String title;
  final String raceName;
  final String? subtitle; // 副标题设为可选参数
  const RaceNameCard({
    Key? key,
    required this.title,
    required this.raceName,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        tileColor: Theme.of(context).canvasColor,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        // 根据是否传入副标题来显示
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          final raceBar = '$raceName/$title'; // 更清晰的参数组合方式
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => shortDistancePage(
                raceBar: raceBar,
                raceEventName: raceName,
              ),
            ),
          );
        },
      ),
    );
  }
}
