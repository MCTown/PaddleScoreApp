import 'package:flutter/material.dart';

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
            // 添加一些 Padding 使列表不紧贴屏幕边缘
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                RaceNameCard(
                  title: '6000米长距离赛（青少年3000米）',
                  raceName: raceName,
                  subtitle: "点击进入",
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
                RaceNameCard(
                  title: '个人积分',
                  raceName: raceName,
                  subtitle: "点击导出总积分",
                ),
              ],
            )));
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
