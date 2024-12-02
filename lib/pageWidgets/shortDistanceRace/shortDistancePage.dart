import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RaceStageCard.dart';
import 'RaceStateWidget.dart';
import 'RaceTimelineWidget.dart';

class shortDistancePage extends StatefulWidget{
  final String raceBar;
  final String raceEventName;
  const shortDistancePage(
  {super.key,required this.raceBar,required this.raceEventName}
      );
  @override
  State<shortDistancePage> createState() => _SprintRacePageState();
}
class _SprintRacePageState extends State<shortDistancePage>{
  List<String> divisions = [
    'U9组男子',
    'U9组女子',
    'U12组男子',
    'U12组女子',
    'U15组男子',
    'U18组男子',
    'U18组女子',
    '充气板组男子',
    '充气板组女子',
    '大师组男子',
    '大师组女子',
    '高校甲组男子',
    '高校甲组女子',
    '高校乙组男子',
    '高校乙组女子',
    '卡胡纳组男子',
    '卡胡纳组女子',
    '公开组男子',
    '公开组女子',
  ];
  late Widget searchBar;
  String _selectedDivision = 'U9组男子';
  String _searchText = '';
  final _typeAheadController = TextEditingController();
  late int totalAccount;
  late int raceAccount;
  List<RaceState> _raceStates = [];
  bool _isLoading = true;
  @override
  void initState(){
      super.initState();
      _loadRaceStates();
      totalAccount = 0;
      raceAccount = 0;
      if(widget.raceBar.contains('趴板')){
        divisions = divisions.where((division)=>division.startsWith('U')).toList();
      }
      void performSearch(String searchText){
        final matchedDivision = divisions.firstWhere((division)=>division.contains(searchText),orElse:()=>'',);
        setState((){
          _selectedDivision = matchedDivision;
          _searchText = searchText;
        });
      }
      searchBar = Row(
        children: [
          Expanded(
            child:
            TypeAheadField(
              textFieldConfiguration:  TextFieldConfiguration(
                decoration:InputDecoration(
                  hintText: '搜索组别',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  // suffixIcon: IconButton(
                  //   icon:const Icon(Icons.search),
                  //   onPressed: (){
                  //     performSearch(_typeAheadController.text);
                  //   },
                  // ),
                ),
                controller: _typeAheadController,
                onSubmitted: (text){
                  performSearch(text);
                }
            ),
            suggestionsCallback: (pattern){
              return divisions.where((division)=>division.contains(pattern)).toList();
            },
            itemBuilder: (context,suggestion){
              return ListTile(
                  title:Text(suggestion),
                  onTap:(){
                    _typeAheadController.text = suggestion;
                    performSearch(suggestion);
                  }
              );
            },
            onSuggestionSelected: (suggestion){
              setState(() {
                _selectedDivision = suggestion;
                _searchText = suggestion;
                _typeAheadController.text = suggestion;
              });
            },
          ),
          ),
          // SizedBox(
          //   height: 40,
          //   child:ElevatedButton(
          //       onPressed: (){
          //         performSearch(_typeAheadController.text);
          //       },
          //       child: const Text('搜索'),
          //   ),
          // ),
        ],
      );
  }

  Future<void> _loadRaceStates() async{
    final prefs = await SharedPreferences.getInstance();
    final raceStatesJson = prefs.getStringList('$_selectedDivision-raceStates');
    if(raceStatesJson != null){
      setState(() {
        _raceStates = raceStatesJson.map((json)=>RaceState.fromJson(jsonDecode(json))).toList();
      });
    }else{
      _raceStates = await getRaceProcess(_selectedDivision);
      _saveRaceStates();
    }
  }
  Future<List<RaceState>> _getRaceStates()async{
    return _raceStates;
  }
  Future<void> _saveRaceStates() async{
    final prefs = await SharedPreferences.getInstance();
    final raceSatesJson = _raceStates.map((raceState)=>jsonEncode(raceState.toJson())).toList();
    await prefs.setStringList('$_selectedDivision-raceSates', raceSatesJson);
  }

  void _onRaceStageStatusChanged(int index,RaceStatus newStatus){
    setState(() {
      _raceStates[index] = _raceStates[index].copyWith(status: newStatus);
    });
    // setState(() {
    // });
    _saveRaceStates();
  }
  Map<String,bool> _hoveringStates = {};

  Widget createNavi(String text){
    _hoveringStates[text] = _hoveringStates[text] ?? false;
    final isSearchResult = _searchText.isNotEmpty && text.contains(_searchText);
    final isHover = _hoveringStates[text]!;
    final isSelected = _selectedDivision == text;
    return MouseRegion(
      onExit: (event){
        setState(() {
          _hoveringStates[text] = false;
        });
      },
      child:InkWell(
        onTap: (){
          setState(() {
            _selectedDivision = text;
            _searchText = '';
          });
        },
        onHover:(isHovering){
          if (!isSelected) {
            setState(() {
              _hoveringStates[text] = isHovering;
            });
          }
        },
        child:AnimatedContainer(
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
            boxShadow:isHover||isSelected || isSearchResult == text
                ?[const BoxShadow(color: Colors.black),]
                :[],
            color: isSelected || isSearchResult
                ? Colors.black
                : isHover
                ? Colors.purple[50] // 悬浮时设置为紫色
                : null, // 其他情况为默认颜色
          ),
          child:ListTile(
            title:Text(text,
              style: TextStyle(
                color: isSelected || isSearchResult
                    ? Colors.white
                    : isHover
                    ? Colors.black // 悬浮时设置为黑色
                    : Colors.black,
              ),
            ),
            iconColor:  isSelected || isSearchResult
                ? Colors.white // 选中或搜索结果时设置为白色
                : isHover
                ? Colors.black // 悬浮时设置为黑色
                : Colors.black,
            // leading: const Icon(Icons.sports_motorsports),
            leading: const Icon(Icons.label_outline),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            tileColor:  isSelected || isSearchResult
                ? Colors.black
                : isHover
                ? Colors.purple[50] // 悬浮时设置为紫色
                : null,
            selected:  _selectedDivision == text,
            selectedTileColor: Colors.black,
          ),
        ),
      ),
    );

  }

  Future<List<RaceState>> getRaceProcess(String division)async{
    int athleteCount =  await getAthleteCountByDivision(widget.raceEventName,_selectedDivision);
    totalAccount = athleteCount;
    if(athleteCount <= 16){
      raceAccount=1;
      return[RaceState(name: "决赛",status:RaceStatus.notStarted),];
    }else if(athleteCount>16 && athleteCount <= 64){
      raceAccount = 2;
      return [
        RaceState(name: '初赛',status: RaceStatus.notStarted),
        RaceState(name: '决赛', status: RaceStatus.notStarted),
      ];
    }else if(athleteCount > 64 && athleteCount <= 128 ){
      raceAccount = 3;
      return [
        RaceState(name: '初赛',status: RaceStatus.notStarted),
        RaceState(name: ' 1/2\n决赛', status: RaceStatus.notStarted),
        RaceState(name: '决赛', status: RaceStatus.notStarted),
      ];
    }else{
      raceAccount = 4;
      return [
        RaceState(name: "初赛", status: RaceStatus.notStarted),
        RaceState(name: "1/4\n决赛", status: RaceStatus.notStarted),
        RaceState(name: "1/2\n决赛", status: RaceStatus.notStarted),
        RaceState(name: "决赛", status: RaceStatus.notStarted)
      ];
    }

  }


 @override
  Widget build(BuildContext context){
   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.primaryContainer,
     appBar:AppBar(
       title:Text(widget.raceBar),
     ),
     body:Stack(
       children: [
         Row(
           children: [
             Expanded(
               flex: 1,
                 child: Column(
                   children: [
                     Expanded(
                       child:SizedBox(
                         // width: 200,
                         child: Container(
                           decoration: BoxDecoration(
                             color:Colors.white,
                             boxShadow:[
                               BoxShadow(
                                 color:Colors.grey.withOpacity(0.5),
                                 spreadRadius: 2,
                                 blurRadius: 5,
                                 offset: const Offset(3, 3),
                               )
                             ]
                           ),
                           child:
                           widget.raceBar.contains('趴板')
                               ?ListView(
                               children: [
                                 createNavi('U9组男子'),
                                 createNavi('U9组女子'),
                                 createNavi('U12组男子'),
                                 createNavi('U12组女子'),
                                 createNavi('U15组男子'),
                                 createNavi('U15组女子'),
                                 createNavi('U18组男子'),
                                 createNavi('U18组女子'),])
                               :ListView(
                             children: [
                               createNavi('U9组男子'),
                               createNavi('U9组女子'),
                               createNavi('U12组男子'),
                               createNavi('U12组女子'),
                               createNavi('U15组男子'),
                               createNavi('U15组女子'),
                               createNavi('U18组男子'),
                               createNavi('U18组女子'),
                               createNavi('充气板组男子'),
                               createNavi('充气板组女子'),
                               createNavi('大师组男子'),
                               createNavi('大师组女子'),
                               createNavi('高校甲组男子'),
                               createNavi('高校甲组女子'),
                               createNavi('高校乙组男子'),
                               createNavi('高校乙组女子'),
                               createNavi('卡胡纳组男子'),
                               createNavi('卡胡纳组女子'),
                               createNavi('公开组男子'),
                               createNavi('公开组女子'),
                             ],
                           ),
                         )
                       ),
                     ),
                   ],
                 ),
             ),
          Expanded(
            flex:5,
            child: _buildContent(_selectedDivision),),
           ],
         ),
         Positioned(
           top:16,
           right: 16,
           child:SizedBox(
             width: 200,
             height: 40,
             child:searchBar,
           )
         )

       ],
     ),
   );
 }
  Widget _buildContent(String division){
    final raceProcess = getRaceProcess(division);
    return Column(
      children:[
        const SizedBox(height: 80,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Card(
            child:
            Column(
              children: [
                ExpansionTile(
                  leading: FaIcon(FontAwesomeIcons.safari,color: Colors.purple[200],),
                  title: Text("$_selectedDivision赛事进度",style: const TextStyle(fontSize: 18),),
                  subtitle: Text('总人数: $totalAccount   总比赛场数: $raceAccount',style: const TextStyle(fontSize: 13),),
                  children: [
                    Stack(
                      children: [
                        // 进度条居中显示
                        Center(
                          child: RaceTimeline(
                              raceStates: _getRaceStates(),
                              onStatusChanged:_onRaceStageStatusChanged),
                        ),
                        // 图例位于右下角，并且距离边框留有一定的间距
                        const Positioned(
                          bottom: 10.0, // 设置距离底部的间距
                          right: 50.0,  // 设置距离右边的间距
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // 让文本右对齐
                            children: [
                              Text("🔵 赛事进行中"),
                              Text("🟢 赛事已完成"),
                              Text("⚪ 赛事未开始"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ),
        ),
        if(!_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: IgnorePointer(
              ignoring: _raceStates.isEmpty,
              child:
              SizedBox(
                height: _raceStates.length * 100,
                child: ListView.builder(
                itemCount:_raceStates.length,
                itemBuilder:(context,index){
                  return RaceStageCard(StageName: _raceStates[index].name,raceName: widget.raceBar.contains('趴板')?'趴板':'竞速',division: _selectedDivision,dbName: widget.raceEventName,index: index,onStatusChanged: _onRaceStageStatusChanged);
                },
                          ),
              ),
            ),
          ),
        FutureBuilder(
          future: raceProcess,
          builder: (context,snapshot){
          if(snapshot.hasData){
            _raceStates = snapshot.data!;
            _isLoading = false;
            // setState(() {});
            return const SizedBox.shrink();
          }else if(snapshot.hasError){
            return Text('Error:${snapshot.error}');
          }else{
            return const CircularProgressIndicator();
          }
        },
        ),
      ]
    );
 }
}