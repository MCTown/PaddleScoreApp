
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RaceStateWidget.dart';

class RaceTimeline extends StatefulWidget{
  final Function(int,RaceStatus) onStatusChanged;
  const RaceTimeline({super.key,required this.onStatusChanged});

  @override
  State<RaceTimeline> createState() => _RaceTimelineState();
}

class _RaceTimelineState extends State<RaceTimeline> {
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return const Placeholder();
  //   return SizedBox(
  //       height: 100,
  //       child:FutureBuilder<List<RaceState>>(
  //         future: widget.raceStates,
  //         builder: (context,snapshot){
  //           if(snapshot.hasData){
  //             return const Placeholder();
  //           }else if(snapshot.hasError){
  //             return Text('Error:${snapshot.error}');
  //           }else{
  //             return const CircularProgressIndicator();
  //           }
  //         },
  //       )
  //
  //   );
  }
}