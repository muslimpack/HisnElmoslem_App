import 'dart:developer' as developer;

void hisnPrint(Object? object) {
  printColor(object, color: PrintColors.green);
}

void printColor(Object? object, {int color = 0}) {
  developer.log(
    colorText(object, color: color),
    name: colorText("HISN ELMOSLEM", color: color),
  );
}

String colorText(Object? object, {int color = 0}) {
  return '\u001b[${color}m$object\u001b[0m';
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
