import 'package:flutter/material.dart';

class TestUnit extends StatelessWidget {
  final String text;
  final IconData icon;
  final dynamic callBack;
  const TestUnit({super.key, required this.text, required this.icon,required this.callBack});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () async {
        // 显示加载对话框
        showDialog(
          context: context,
          barrierDismissible: false, // 点击外部不可关闭
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("加载中..."),
                ],
              ),
            );
          },
        );
        try{
          await callBack();
        } catch (e) {
          print(e);
        }

        // 关闭对话框
        Navigator.of(context).pop();
      },
    );
  }
}