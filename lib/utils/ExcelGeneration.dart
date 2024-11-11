import 'dart:math';

import 'package:excel/excel.dart';
import 'package:paddle_score_app/utils/DatabaseManager.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:sqflite/sqflite.dart';



String randomTimeGenerator() {
  // 生成一个随机的时间 格式为hh:mm.ss
  Random random = Random();
  int hour = random.nextInt(24);
  int minute = random.nextInt(60);
  int second = random.nextInt(60);
  // 0.1的概率为DNS
  if (random.nextInt(10) == 0) {
    return 'DNS';
  }
  // 0.05的概率为DNF
  if (random.nextInt(20) == 0) {
    return 'DNF';
  }
  // 0.005的概率为DSQ
  if (random.nextInt(500) == 0) {
    return 'DSQ';
  }
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
}


