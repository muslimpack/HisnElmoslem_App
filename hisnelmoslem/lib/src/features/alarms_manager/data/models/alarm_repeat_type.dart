import 'package:get/get.dart';

enum AlarmRepeatType {
  daily,
  atSaturday,
  atSunday,
  atMonday,
  atTuesday,
  atWednesday,
  atThursday,
  atFriday,
}

extension AlarmRepeatTypeExtension on AlarmRepeatType {
  String getUserFriendlyName() {
    switch (this) {
      case AlarmRepeatType.daily:
        return "daily".tr;
      case AlarmRepeatType.atSaturday:
        return "every saturday".tr;
      case AlarmRepeatType.atSunday:
        return "every sunday".tr;
      case AlarmRepeatType.atMonday:
        return "every monday".tr;
      case AlarmRepeatType.atTuesday:
        return "every tuesday".tr;
      case AlarmRepeatType.atWednesday:
        return "every wednesday".tr;
      case AlarmRepeatType.atThursday:
        return "every thursday".tr;
      case AlarmRepeatType.atFriday:
        return "every Friday".tr;
    }
  }
}
