import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'package:paddle_score_app/pageWidgets/appEntrances/racesEntrancePage.dart';

class HomePageContent extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState2 = context.watch<MyAppState>();
    var counts = appState2.createCount;
    void showAddRaceDialog(){
      TextEditingController controller = TextEditingController();
      showDialog(
        context:context,
        builder:(context){
          return AlertDialog(
            title:const Text('创建赛事'),
            content:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: '请输入赛事名称'),
                ),
                const SizedBox(height:16),
              ],
            ),
            actions:[
              TextButton(
                onPressed:(){
                  Navigator.of(context).pop();
                },
                child:const Text('取消'),
              ),
              TextButton(
                onPressed:(){
                  appState2.addRace(controller.text);
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title:const Text('PaddleScoreApp demo')),
      body:Container(
        color:Theme.of(context).colorScheme.primaryContainer,
        child:Center(
          child:Card(
            child:Padding(
              padding: const EdgeInsets.all(16.0),
              child:Column(
                mainAxisSize:MainAxisSize.min,
                children:[
                  Text('请创建或查看赛事，目前已创建$counts', style:const TextStyle(fontSize:16),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}