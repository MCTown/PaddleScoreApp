import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class longDistanceRacePage extends StatelessWidget{
  const longDistanceRacePage({
    super.key,
    required this.raceBar,
});
  final dynamic raceBar;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:Text(raceBar),
      ),
      body:Center(
        child:Text('这是 $raceBar 的竞赛页面')
      ),
    );
  }
}