import 'dart:developer';

import 'package:flutter/foundation.dart';

void hisnPrint(Object? object) {
  final fileNameAndLine = getFileNameAndLine();
  final methodName = getCurrentMethodName2();
  printColor(
    object,
    color: PrintColors.green,
    name: "$methodName=>$fileNameAndLine",
  );
}

void printColor(Object? object, {int color = 0, String name = "HISN"}) {
  final orangeText = '\u001b[${color}m$object\u001b[0m';
  if (kDebugMode) {
    log(orangeText, name: name);
  }
}

String getCurrentMethodName() {
  final frames = StackTrace.current.toString().split('\n');
  final frame = frames.elementAtOrNull(1);

  if (frame != null) {
    final tokens = frame
        .replaceAll('<anonymous closure>', '<anonymous_closure>')
        .split(' ');

    final methodName = tokens.elementAtOrNull(tokens.length - 2);
    if (methodName != null) {
      final methodTokens = methodName.split('.');
      return methodTokens.length >= 2 &&
              methodTokens[1] != '<anonymous_closure>'
          ? (methodTokens.elementAtOrNull(1) ?? '')
          : methodName;
    }
  }
  return '';
}

String getCurrentMethodName2() {
  final frames = StackTrace.current.toString().split('\n');
  final frame = frames.elementAtOrNull(2);

  if (frame != null) {
    final tokens = frame
        .replaceAll('<anonymous closure>', '<anonymous_closure>')
        .split(' ');

    final methodName = tokens.elementAtOrNull(tokens.length - 2);
    if (methodName != null) {
      final methodTokens = methodName.split('.');
      return methodTokens.length >= 2 &&
              methodTokens[1] != '<anonymous_closure>'
          ? (methodTokens.elementAtOrNull(1) ?? '')
          : methodName;
    }
  }
  return '';
}

String getFileNameAndLine() {
  final frames = StackTrace.current.toString().split('\n');
  final frame = frames.elementAtOrNull(2);
  // final frame = frames.elementAtOrNull(1);

  if (frame != null) {
    final tokens = frame
        .replaceAll('<anonymous closure>', '<anonymous_closure>')
        .split(' ');

    final methodName = tokens.elementAtOrNull(tokens.length - 1);
    if (methodName != null) {
      final methodTokens = methodName.split('/').last.replaceAll(")", "");
      return methodTokens;
    }
  }
  return '';
}

class PrintColors {
  static int black = 30;
  static int red = 31;
  static int green = 32;
  static int yellow = 33;
  static int blue = 34;
  static int magenta = 35;
  static int cyan = 36;
  static int white = 37;
}

String get fullTimeStamp {
  // Get the current time
  final DateTime now = DateTime.now();

  // Extract hours, minutes, and seconds
  final String hour = now.hour.toString().padLeft(2, "0");
  final String minute = now.minute.toString().padLeft(2, "0");
  final String second = now.second.toString().padLeft(2, "0");
  final String millisecond = now.millisecond.toString().padLeft(3, "0");

  return '$hour:$minute:$second:$millisecond';
}
