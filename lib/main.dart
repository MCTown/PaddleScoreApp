import 'package:flutter/material.dart';
import 'package:paddle_score_app/page_widgets/race_page.dart';
import 'package:provider/provider.dart';
import '/page_widgets/home_page_content.dart';
import 'page_widgets/createRacePage.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context)=>MyAppState(),
      child:MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("Learning widget built");
    return MaterialApp(
      title: 'PaddleScore demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyAppState extends ChangeNotifier {
  List<String> races = [];
  int createCount = 0;
  void addRace(String raceName) {
    races.add(raceName);
    createCount++;
    notifyListeners();
  }

}

class _MyHomePageState extends State<MyHomePage> {
  bool isRailExtended=true;
  int selectedIndex = 0;
  void navigateToPage(int index){
    setState(() {
      selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    Widget page;
    int size = appState.races.length;
    switch(selectedIndex){
      case 0:
        page = HomePageContent() as Widget;
        break;
      case 1:
        page = Placeholder() as Widget;
        break;
      case 2:
        page = CreateRacePage();
      default:
        page = RacePage(raceName: appState.races[size-selectedIndex+2])as Widget;
        break;
    }
    return LayoutBuilder(
      builder: (context,constraints){
        var navigationWidth = constraints.maxWidth*0.13;
        return Scaffold(
          body:Row(
            children: [
              AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: isRailExtended ? navigationWidth : 50,
                  padding:EdgeInsets.only(top:16.0,right: 6),
                  child:Stack(
                    children: [
                      if(isRailExtended)
                        SafeArea(child:
                        Padding(
                          padding: const EdgeInsets.only(top: 27),
                          child: NavigationRail(
                            extended: constraints.maxWidth>=700,
                            selectedIndex:selectedIndex,
                            onDestinationSelected:(value){
                              navigateToPage(value);
                            },
                            destinations:[
                              const NavigationRailDestination(
                                icon:Icon(Icons.home),
                                label:Text('首页'),
                              ),
                              const NavigationRailDestination(
                                icon:Icon(Icons.settings),
                                label:Text('管事赛事'),
                              ),
                              const NavigationRailDestination(
                                  icon:Icon(Icons.add),
                                  label: Text('创建赛事')
                              ),
                              for(var i = appState.races.length-1; i >=0; i--)
                                  NavigationRailDestination(
                                    icon: Icon(Icons.start),
                                    label: Text(appState.races[i]),
                                  )
                            ],
                          ),
                        ),
                        ),
                      Positioned(
                        top:0,
                        right:0,
                        child:IconButton(
                          icon:Icon(isRailExtended?Icons.arrow_back:Icons.menu),
                          onPressed:(){
                            setState((){
                              isRailExtended = !isRailExtended;
                            });
                          },
                        ),
                      ),
                    ],
                  )
              ),
              Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    )
                )
            ],
          )
        );
      }
    );
  }
}




