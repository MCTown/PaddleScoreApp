import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SprintRacePage extends StatefulWidget{
  final String raceBar;
  final String raceEventName;
  const SprintRacePage(
  {super.key,required this.raceBar,required this.raceEventName}
      );
  @override
  State<SprintRacePage> createState() => _SprintRacePageState();
}
class RaceState{
  final String name;
  final RaceStatus status;
  RaceState({required this.name,required this.status});
}
enum RaceStatus{
  completed,
  ongoing,
  notStarted,
}
class RaceTimeline extends StatelessWidget{
  final List<RaceState> raceStates;
  const RaceTimeline({super.key,required this.raceStates});
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        raceStates.asMap().entries.map((entry){
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
                lineColor = Colors.grey[100];
                break;
              case RaceStatus.notStarted:
                dotColor = Colors.grey[100];
                lineColor = Colors.grey[100];
                break;
            }
          return Row(
            children: [
              // 第一个圆点和阶段名称
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
                child: Center(child: Text(stage.name)),
              ),
              // 连接圆点的直线
              if (index < raceStates.length - 1)
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
      ),
    );
  }
}
class _SprintRacePageState extends State<SprintRacePage>{
  final List<String> divisions = [
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
  @override
  void initState(){
      super.initState();
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
  List<RaceState> getRaceProcess(String division){
    return [
      RaceState(name: '初赛',status: RaceStatus.notStarted),
      RaceState(name: '复赛', status: RaceStatus.notStarted),
      RaceState(name: '决赛', status: RaceStatus.notStarted),
    ];
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
                           child: ListView(
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
        SizedBox(height: 100,),
        RaceTimeline(raceStates: raceProcess),
      ]
    );
 }
}