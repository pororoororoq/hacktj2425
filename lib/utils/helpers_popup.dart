import 'package:flutter/material.dart';

Future<void> showStyledDialog({
  required BuildContext context,
  required String content,
  String buttonText = 'OK',
  VoidCallback? onButtonPressed,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // 화이트 바탕화면
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              content,
              style: Theme.of(context).textTheme.titleLarge, // 텍스트 스타일 설정
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              buttonText,
              style: Theme.of(context).textTheme.headlineLarge, // 버튼 텍스트 스타일 설정
            ),
            onPressed: () {
               if (onButtonPressed != null) {
                onButtonPressed();
              } else {
                Navigator.of(context).pop(); // 기본적으로 다이얼로그를 닫음
              }
            },
          ),
        ],
      );
    },
  );
}