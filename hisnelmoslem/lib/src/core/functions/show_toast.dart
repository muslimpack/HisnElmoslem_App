import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';

Future<void> showToast({
  required String msg,
  Toast toastLength = Toast.LENGTH_SHORT,
}) async {
  if (PlatformExtension.isDesktop) {
    BotToast.showText(
      text: msg,
      align: Alignment.bottomCenter,
      textStyle: const TextStyle(
        color: Colors.white,
      ),
      duration: Duration(seconds: toastLength == Toast.LENGTH_SHORT ? 1 : 5),
      contentPadding: const EdgeInsets.all(10),
    );
  } else {
    Fluttertoast.showToast(
      backgroundColor: Colors.black.withOpacity(.5),
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }
}
