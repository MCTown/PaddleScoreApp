import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../DataHelper.dart';
import '../../utils/GlobalFunction.dart';

class RaceStageCard extends StatefulWidget{
  final String StageName;
  final String raceName;
  final String division;
  final String dbName;
  final int index;
  final Function(int,RaceStatus) onStatusChanged;
  RaceStageCard({super.key,required this.StageName,required this.raceName,required this.division,required this.dbName,required this.index,required this.onStatusChanged});

  @override
  State<RaceStageCard> createState() => _RaceStageCardState();
}

class _RaceStageCardState extends State<RaceStageCard> {
  @override
  Widget build(BuildContext context) {
    CType raceType = widget.raceName=='趴板'? CType.pronePaddle:CType.sprint;
    SType stageType;
    print(widget.division);
    switch(widget.StageName){
      case '初赛':
        stageType = SType.firstRound;
        break;
      case '1/8\n决赛':
        stageType = SType.roundOf16;
        break;
      case '1/4\n决赛':
        stageType = SType.quarterfinals;
        break;
      case '1/2\n决赛':
        stageType = SType.semifinals;
        break;
      case '决赛':
        stageType = SType.finals;
        break;
      default:
        throw Exception('未知的比赛阶段');
    }
    bool isCompleted = false;
    return Container(
      height: 100,
      child: Card(
          child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.emoji_events,color: Colors.brown,),
                  SizedBox(width: 10,),
                  Text(
                    widget.StageName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 130,),
                      ElevatedButton(
                        onPressed: ()async{
                          print('导出分组名单');
                          List<int>? excelFileBytes = await DataHelper.generateGenericExcel(widget.division, raceType, stageType, widget.dbName);
                          if(excelFileBytes == null){
                            throw Exception("生成Excel失败");
                          }
                          Future.delayed(Duration.zero,()async{
                            String? filePath = await FilePicker.platform.saveFile(
                              dialogTitle:'导出${widget.division} _${widget.raceName} _${widget.StageName}分组名单(登记表)',
                              fileName:'${widget.division} _${widget.raceName} _${widget.StageName}成绩登记表.xlsx',
                            );
                            if(filePath == null){
                              throw Exception("用户未选择文件");
                            }
                            File file = File(filePath);
                            await file.writeAsBytes(excelFileBytes);
                            print("文件已保存到: $filePath");
                            widget.onStatusChanged(widget.index,RaceStatus.ongoing);
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0)
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                          ),
                          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                          elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return 16.0;
                            }
                            return 4.0;
                          }),
                          overlayColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child:const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("导出分组名单",style: TextStyle(fontSize: 16),),
                            SizedBox(width: 10.0,),
                            Icon(Icons.file_download,color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(width: 130,),
                      ElevatedButton(
                        onPressed: ()async{
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xlsx'],
                            withData: true,
                            allowMultiple: false,
                          );
                          if(result == null){
                            throw("用户未导入文件");
                          }
                          isCompleted = true;
                          List<int> fileBytes = File(result.paths.first!).readAsBytesSync();
                          DataHelper.importGenericCompetitionScore(widget.division, fileBytes, raceType, stageType, widget.dbName);
                          print("导入${widget.StageName}成绩");
                          widget.onStatusChanged(widget.index,RaceStatus.completed);
                          setState(() {
                            isCompleted = true;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0)
                          ),
                          shape: WidgetStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                          ),
                          shadowColor: WidgetStateProperty.all<Color>(Colors.black),
                          elevation: WidgetStateProperty.resolveWith<double>((Set<MaterialState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return 16.0;
                            }
                            return 3.0;
                          }),
                          overlayColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isCompleted ? Text("已导入${widget.StageName.replaceAll('\n', '')}成绩",style: const TextStyle(fontSize: 16))
                             : Text("导入${widget.StageName.replaceAll('\n', '')}成绩",style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 10.0,),
                            const Icon(Icons.file_upload,color: Colors.black,),
                          ],
                        ),),
                    ],
                  )
                ],
              )
          )
      ),
    );
  }
}