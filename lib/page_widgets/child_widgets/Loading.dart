import 'package:flutter/material.dart';

class Loading {
  static void startLoading(context) {
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
        });
  }

  static void stopLoading(context) {
    Navigator.of(context).pop();
  }
}
