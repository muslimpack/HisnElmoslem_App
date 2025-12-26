import 'dart:developer';

import 'package:flutter/foundation.dart';

void hisnPrint(Object? object) {
  final location = getFileNameAndLine();
  final method = getCurrentMethodName();

  final prettyLog = '''${location.replaceAll("package:hisnelmoslem/", "lib/")} | $method''';

  printColor(object, color: PrintColors.green, name: "HISN] [$prettyLog");
}

void printColor(Object? object, {int color = 0, String name = "HISN"}) {
  final orangeText = '\u001b[${color}m$object\u001b[0m';
  if (kDebugMode) {
    log(orangeText, name: name);
  }
}

String getCurrentMethodName() {
  final frames = StackTrace.current.toString().split('\n');
  final frame = frames.elementAtOrNull(2) ?? "";

  // Extract something like: ClassName.methodName
  final regex = RegExp(r'#\d+\s+([A-Za-z0-9_<>]+)\.([A-Za-z0-9_<>]+)');
  final match = regex.firstMatch(frame);

  if (match != null) {
    return "${match.group(1)}.${match.group(2)}";
  }

  return "UnknownMethod";
}

String getFileNameAndLine() {
  final frames = StackTrace.current.toString().split('\n');
  final frame = frames.elementAtOrNull(2) ?? "";

  final regex = RegExp(r'\((.*?):(\d+):(\d+)\)');
  final match = regex.firstMatch(frame);

  if (match == null) return "unknown_file";

  final fullPath = match.group(1) ?? "";
  final line = match.group(2) ?? "";
  final col = match.group(3) ?? "";

  return "$fullPath:$line:$col";
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
