
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
              final raceStateList = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                _raceStates.asMap().entries.map((entry){
                  final index = entry.key;
                  final stage = entry.value;

                  Color? dotColor;
                  Color? lineColor;
                  switch (stage.status){
                    case RaceStatus.completed:
                      dotColor = Colors.green;
                      lineColor = Colors.green;
                      break;
                    case RaceStatus.ongoing:
                      dotColor = Colors.blue;
                      lineColor = Colors.white;
                      break;
                    case RaceStatus.notStarted:
                      dotColor = Colors.white;
                      lineColor = Colors.white;
                      break;
                  }
                  return Row(
                    children: [
                      // 第一个圆点和阶段名称
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                          boxShadow: [
                            BoxShadow(
                              color:Colors.grey.withOpacity(0.5),
                              spreadRadius:2,
                              blurRadius: 5,
                              offset: Offset(0,3),
                            )
                          ],
                        ),
                        child: Center(child: Text(stage.name)),
                      ),
                      // 连接圆点的直线
                      if (index < raceStateList.length - 1)
                        SizedBox(
                          width: 200,
                          child: Container(
                            height: 5,
                            color:lineColor,
                          ),
                        ),
                      // CustomPaint(
                      //   size: Size(100, 10), // 根据需要调整宽度
                      //   painter: LinePainter(color: Colors.grey),
                      // ),
                    ],
                  );
                }).toList(),
              );
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