import 'package:flutter/material.dart';

import '../../utils/SettingService.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService();
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 加载设置
  Future<void> _loadSettings() async {
    await _settingsService.loadSettings();
    setState(() {
      _isDarkMode = _settingsService.getSetting('isDarkMode') ?? false;
      _selectedLanguage = _settingsService.getSetting('language') ?? 'English';
    });
  }

  // 更新设置
  Future<void> _updateSetting(String key, dynamic value) async {
    await _settingsService.updateSetting(key, value);
    // 发送一个消息
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),

      ),
    );
    setState(() {
      if (key == 'isDarkMode') _isDarkMode = value;
      if (key == 'language') _selectedLanguage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // 夜间模式开关
          Card(
            child: ListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Enable or disable dark mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) => {_updateSetting('isDarkMode', value)},
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // 语言选择
          Card(
            child: ListTile(
              title: Text('Language'),
              subtitle: Text('Select your preferred language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) =>
                    _updateSetting('language', newValue!),
                items: ['English', '简体中文', 'Español', 'Français']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
