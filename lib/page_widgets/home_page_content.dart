import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '/page_widgets/race_page.dart';

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
                ElevatedButton(
                  onPressed:()async{
                    final result = await FilePicker.platform.pickFiles(
                      type:FileType.custom,
                      allowedExtensions: ['xlsx','xls'],
                    );
                    if(result!=null){
                      final file = result.files.first;
                      if(file!=null && file.path!=null) {
                        final filePath = file.path;
                        print('选中的文件路径：$filePath');
                      }
                    }else{
                      print('用户未选择文件');
                    }
                  },
                  child: const Text('上传参赛人员名单'),
                ),
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
                  const SizedBox(height:16),
                  ElevatedButton(
                    style:ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(200, 50)),
                        side:WidgetStateProperty.all(
                            BorderSide(color:Colors.grey.shade400,width:1)
                        )
                    ),
                    onPressed:(){
                      showAddRaceDialog();
                    },
                    child:const Text('创建赛事',style:TextStyle(fontSize:16)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}