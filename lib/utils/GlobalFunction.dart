import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getFilePath(String? fileName) async {
  final directory = await getApplicationDocumentsDirectory();
// 若PaddleScoreData文件夹不存在，则创建
  final path = '${directory.path}/PaddleScoreData';
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync();
  }
  if (fileName == null) {
    return path;
  }
  return '$path/$fileName';
}
