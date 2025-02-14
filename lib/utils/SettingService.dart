import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paddle_score_app/utils/GlobalFunction.dart';
import 'package:path_provider/path_provider.dart';

class SettingService {
  static Future<File> getSettingFile() async {
    final directory = await getFilePath("config.json");
    return File(directory);
  }

  static Future<void> loadSettings() async {
    final file = await getSettingFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      SettingService.settings = json.decode(contents);
    } else {
      // 如果文件不存在，则创建并写入默认设置
      await saveSettings();
    }
    print('Settings loaded: $settings');
    // print('Settings loaded: $settings');
  }

  static Map<String, dynamic> settings = {
    // 默认设置
    'isDebugMode': false,
    'shortNumber': 16,
  };

  static void updateSetting(String key, dynamic value) {
    settings[key] = value;
  }

  static Future<void> saveSettings([context]) async {
    // todo
    File settingsFile = await getSettingFile();
    await settingsFile.writeAsString(json.encode(settings));
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
        ),
      );
    }
    loadSettings();
  }
}
