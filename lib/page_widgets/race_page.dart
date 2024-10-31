import 'package:flutter/material.dart';
enum raceType{
  longRace,
  shortRace,
  teamRace,
}
Widget raceCard(raceType rt){
  String title;
  switch(rt){
    case raceType.longRace:
      title = '长距离赛';
      break;
    case raceType.shortRace:
      title = '短距离赛';
      break;
    case raceType.teamRace:
      title = '团体赛';
      break;
  }
  return SizedBox(
    width:900,
    height:200,
    child:Card(
      child:Padding(
        padding:const EdgeInsets.all(16.0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Center(
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.center,
                children:[
                  Text(title,style:const TextStyle(
                      fontSize:46)),
                ],
              ),
            ),
            const Wrap(
              children:[
                Text('查看'),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class RacePage extends StatelessWidget{
  final String raceName;
  const RacePage({Key? key,required this.raceName}):super(key:key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar:AppBar(
        title:Text(raceName),
      ),
      body:Center(
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            raceCard(raceType.longRace),
            const Divider(
              thickness:2,
              endIndent: 800,
              indent: 0,
            ),
            raceCard(raceType.shortRace),
            const Divider(
              thickness:2,
              endIndent: 0,
              indent: 800,
            ),
            raceCard(raceType.teamRace),
          ]
        )
      )
    );
  }
}