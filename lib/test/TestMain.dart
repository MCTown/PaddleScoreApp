import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:paddle_score_app/test/TestPage.dart';

import '../main.dart';
import '../pageWidgets/appEntrances/createRacePage.dart';
import '../pageWidgets/appEntrances/racesEntrancePage.dart';
import '../utils/Routes.dart';

void main() {
  // 初始化数据库工厂
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Learning widget built");
    return MaterialApp(
        title: 'PaddleScoreApp 演示',
        debugShowCheckedModeBanner: false,
        // 取消右上角的DEBUG标记
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: routes,
        home: TestPage());
  }
}
