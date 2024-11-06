import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'longDistanceRace_page.dart';
enum RaceType{
  longRace,
  shortRace1,
  shortRace2,
  teamRace,
  personalScore,
}
class RaceCardState extends ChangeNotifier{
  String raceEventName = '';
}
class RaceCard extends StatefulWidget{
  final RaceType rt;
  const RaceCard({super.key,required this.rt});
  @override
  State<RaceCard> createState()=>_RaceCard();
}
class _RaceCard extends State<RaceCard>{
  bool isHovering = false;
  @override
  Widget build(BuildContext context){
    RaceType rt = widget.rt;
    String title;
    switch(rt){
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
        title  = '个人积分';
        break;
    }
    return LayoutBuilder(
      builder:(BuildContext context,BoxConstraints constraints) {
        var raceCardState_ = context.watch<RaceCardState>();
        String raceName = raceCardState_.raceEventName;
        double cardWidth = constraints.maxWidth*0.7 ;
        return SizedBox(
          width: cardWidth,
          height: 100,
          child: InkWell(
              onTap: () {
                final raceBar = '$raceName/$title';
                print('点击了$title');
                switch(rt){
                 case RaceType.longRace:
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder:(context)=>LongDistanceRacePage(raceBar:raceBar, raceEventName:raceName),
                     ),
                   );
                   break;
                  case RaceType.shortRace1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(context)=>LongDistanceRacePage(raceBar:raceBar, raceEventName:raceName),
                      ),
                    );
                    break;
                    case RaceType.shortRace2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(context)=>LongDistanceRacePage(raceBar:raceBar, raceEventName:raceName),
                      ),
                    );
                    break;
                    case RaceType.teamRace:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(context)=>LongDistanceRacePage(raceBar:raceBar, raceEventName:raceName),
                      ),
                    );
                    break;
                    case RaceType.personalScore:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(context)=>LongDistanceRacePage(raceBar:raceBar, raceEventName:raceName),
                      ),
                    );
                    break;
                }

              },
              onHover: (hovering) {
                setState(() {
                  isHovering = hovering;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isHovering
                          ? [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius:12,
                        ),
                      ] : [
                        const BoxShadow(
                          color: Colors.transparent,
                          blurRadius: 0,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: isHovering ? 10 : 4,
                      shadowColor: isHovering ? Colors.grey:Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // color:Colors.white.withOpacity(isHovering?0.8:1.0),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedOpacity(
                            opacity: isHovering ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(title, style: const TextStyle(
                                        fontSize: 24, color: Colors.black)),
                                  )
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                      opacity: isHovering ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('查看详情', style: TextStyle(
                                  fontSize: 16, color: Colors.purple))
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.purple),
                        ],
                      )
                  )
                ],
              )
          ),
        );
      }
    );
  }
}
class RacePage extends StatelessWidget{
  final String raceName;
  const RacePage({super.key,required this.raceName});
  @override
  Widget build(BuildContext context){
    var raceCardState = context.watch<RaceCardState>();
    raceCardState.raceEventName = raceName;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar:AppBar(
        title:Text(raceName),
      ),
      body:const Center(
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            RaceCard(rt:RaceType.longRace),
            RaceCard(rt:RaceType.shortRace1),
            RaceCard(rt:RaceType.shortRace2),
            RaceCard(rt:RaceType.teamRace),
            RaceCard(rt:RaceType.personalScore),
          ]
        )
      )
    );
  }
}