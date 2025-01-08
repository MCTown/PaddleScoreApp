import 'package:flutter/material.dart';

class Dialog{
  static Stack okDialog(String title, String contents, context) {
    return Stack(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(
                left: 20, top: 45, right: 20, bottom: 20),
            margin: const EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),),
                  const SizedBox(height: 15),
                  Text(contents, style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,),
                  const SizedBox(height: 22,),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                        ),
                        child: const Text(
                          '确定', style: TextStyle(fontSize: 18),),)
                  )
                ]
            )
        )
      ],
    );
  }
}