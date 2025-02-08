import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ErrorHandler {
  static void showErrorDialog(
      BuildContext context, String suggestionMessage, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("导入失败"),
          content: Text("$suggestionMessage\n错误详情: $errorMessage"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }
}
