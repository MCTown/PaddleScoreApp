import 'package:flutter/material.dart';
enum RaceType{
  longRace,
  shortRace,
  teamRace,
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
        title = '长距离竞赛';
        break;
      case RaceType.shortRace:
        title = '短距离竞赛';
        break;
      case RaceType.teamRace:
        title = '团体竞赛';
        break;
    }
    return SizedBox(
      width:900,
      height:200,
      child:InkWell(
        onTap:(){
          print('点击了$title');
        },
        onHover:(hovering){
          isHovering = hovering;
          (context as Element).markNeedsBuild();
        },
        child:Stack(
          alignment: Alignment.center,
          children:[
            AnimatedContainer(
              duration:const Duration(milliseconds: 200),
              curve:Curves.easeInOut,
              decoration:BoxDecoration(
                borderRadius:BorderRadius.circular(12),
                boxShadow: isHovering
                ?[
                  BoxShadow(
                    color:Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ]:[
                  const BoxShadow(
                    color:Colors.transparent,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child:Card(
                elevation:0,
                // shadowColor: isHovering ? Colors.purple:Colors.grey,
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // color:Colors.white.withOpacity(isHovering?0.8:1.0),
                child:Padding(
                  padding:const EdgeInsets.all(16.0),
                  child:AnimatedOpacity(
                      opacity: isHovering?0.0:1.0,
                      duration: const Duration(milliseconds:200),
                      child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Expanded(
                          child:Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Text(title,style:const TextStyle(
                                    fontSize:40)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ),
            AnimatedOpacity(
                opacity: isHovering?1.0:0.0,
                duration: const Duration(milliseconds: 200),
                child:const Row(
                  mainAxisSize:MainAxisSize.min,
                  children: [
                    Text('查看详情',style:TextStyle(fontSize: 36,color:Colors.purple)),
                    Icon(Icons.arrow_forward_ios,color:Colors.purple),
                  ],
                )
            )
          ],
        )
      ),
    );
  }
}

class RacePage extends StatelessWidget{
  final String raceName;
  const RacePage({super.key,required this.raceName});
  @override
  Widget build(BuildContext context){
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
            Divider(
              thickness:3,
              endIndent: 800,
              indent: 0,
            ),
            RaceCard(rt:RaceType.shortRace),
            Divider(
              thickness:3,
              endIndent: 0,
              indent: 800,
            ),
            RaceCard(rt:RaceType.teamRace),
          ]
        )
      )
    );
  }
}