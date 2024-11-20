import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:paddle_score_app/DataHelper.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/ExcelAnalysis.dart';

class CreateRacePage extends StatefulWidget{
  const CreateRacePage({Key? key}) : super(key: key);
  @override
  State<CreateRacePage> createState()=>_CreateRacePage();
}

class _CreateRacePage extends State<CreateRacePage>{
  final _formKey = GlobalKey<FormState>();
  final _raceNameController = TextEditingController();
  FilePickerResult? _selectedFile;
  List<int> bytes = [];

  Future<void> _pickExcelFile() async{
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _selectedFile = result;
          bytes = File(result.paths.first!).readAsBytesSync();
          // print(_selectedFile);
        });
      }
    } catch(e){
      print('Error: $e');
    }
  }

  void _submitForm(){
    MyAppState appState3 = Provider.of<MyAppState>(context, listen: false);
    if (_formKey.currentState!.validate()){
      String raceName = _raceNameController.text;
      //处理Excel文件
      if(_selectedFile!=null && raceName.isNotEmpty) {
        if(appState3.races.contains(raceName)){
          showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title:const Text('赛事创建失败'),
                content:const Text('赛事名称已存在,请输入不同的赛事名称'),
                actions:[
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: const Text('确认'),
                  ),
                ],
              );
            },
          );
          return;
        }else{
          DataHelper.loadExcelFileToAthleteDatabase(raceName,bytes);
        }
        appState3.addRace(_raceNameController.text);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('赛事创建成功'),
              content: Text('赛事名称：$raceName'),
              actions: [
                TextButton(
                  onPressed: () {
                    //跳转到赛事页面
                    Navigator.of(context).pop();
                    appState3.setSelectRace(raceName);
                    Navigator.pushNamed(context, '/race/$raceName');
                  },
                  child: const Text('跳转到赛事页面'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确认并返回'),
                ),
              ],
            );
          },
        );
      }else{
        showDialog(
          context: context,
          builder:(BuildContext context){
            return AlertDialog(
              title:const Text('赛事创建失败'),
              content:raceName.isEmpty
                  ?const Text('赛事名称不能为空')
                  :_selectedFile == null
                    ? const Text('请上传赛事人员名单')
                    :const Text('未知错误'),
              actions:[
                TextButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                  child:const Text('确认'),
                ),
              ],
            );
          }
        );
      }
    }
  }

  void _clearFrom(){
    _formKey.currentState!.reset();
    _raceNameController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:const Text('创建赛事'),
      ),
      body:Container(
        color:Theme.of(context).colorScheme.primaryContainer,
        child: Center(
          child: Padding(
            padding:const EdgeInsets.all(16),
            child:Container(
              width: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(76.0),
              child: Form(
                key:_formKey,
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 450,
                      child:TextFormField(
                        controller:_raceNameController,
                        decoration: const InputDecoration(labelText:'赛事名称',hintText: '请输入赛事名称'),
                        validator:(value){
                          if(value == null || value.isEmpty){
                            return '请输入赛事名称';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height:40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                        ElevatedButton(
                          onPressed:_pickExcelFile,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12 ),
                          ),
                          child:const Text('上传赛事人员名单'),
                        ),
                    ),
                    const SizedBox(height: 15),
                    if(_selectedFile != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child:Padding(
                          padding:const EdgeInsets.only(top:8.0),
                          child: Text('已选择文件：${_selectedFile!.files.first.name}',
                            style: const TextStyle(fontSize: 18),),
                        ),
                      ),
                    const SizedBox(height:39),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        ElevatedButton(
                          onPressed:_clearFrom,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
                          ),
                          child:const Text('清空'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:(){
                            _submitForm();
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
                          ),
                          child:const Text('确认'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}