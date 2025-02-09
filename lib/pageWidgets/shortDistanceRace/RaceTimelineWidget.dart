
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RaceStateWidget.dart';

class RaceTimeline extends StatefulWidget{
  final Future<List<RaceState>> raceStates;
  final Function(int,RaceStatus) onStatusChanged;
  const RaceTimeline({super.key,required this.raceStates,required this.onStatusChanged});

  @override
  State<RaceTimeline> createState() => _RaceTimelineState();
}

class _RaceTimelineState extends State<RaceTimeline> {
  List<RaceState> _raceStates = [];
  @override
  void initState(){
    super.initState();
    widget.raceStates.then((value){
      setState(() {
        _raceStates = value;
      });
    });
  }
  void didUpdateWidget(covariant RaceTimeline oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.raceStates != oldWidget.raceStates){
      widget.raceStates.then((value){
        setState(() {
          _raceStates = value;
        });
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return SizedBox(
        height: 100,
        child:FutureBuilder<List<RaceState>>(
          future: widget.raceStates,
          builder: (context,snapshot){
            if(snapshot.hasData){
              return const Placeholder();
            }else if(snapshot.hasError){
              return Text('Error:${snapshot.error}');
            }else{
              return const CircularProgressIndicator();
            }
          },
        )

    );
  }
}