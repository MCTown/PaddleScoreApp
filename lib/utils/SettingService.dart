import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SettingsService {
  Map<String, dynamic> _settings = {
    "isDarkMode": false,
    "language": "English",
  };

  // 获取配置文件路径
  Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/PaddleScoreData/config.json');
  }

  // 读取设置
  Future<void> loadSettings() async {
    try {
      final file = await _getConfigFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        _settings = json.decode(contents);
      } else {
        // 如果文件不存在，则创建并写入默认设置
        await saveSettings();
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  // 保存设置
  Future<void> saveSettings() async {
    try {
      final file = await _getConfigFile();
      final contents = json.encode(_settings);
      await file.writeAsString(contents);
    } catch (e) {
      print('Failed to save settings: $e');
    }
  }

  // 获取设置值
  dynamic getSetting(String key) => _settings[key];

  // 更新设置值
  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    await saveSettings();
  }
}
