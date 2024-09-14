import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_day.dart';

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
  int getWeekDay() {
    switch (this) {
      case AlarmRepeatType.daily:
        return -1;
      case AlarmRepeatType.atSaturday:
        return AwesomeDay.saturday.value;
      case AlarmRepeatType.atSunday:
        return AwesomeDay.sunday.value;
      case AlarmRepeatType.atMonday:
        return AwesomeDay.monday.value;
      case AlarmRepeatType.atTuesday:
        return AwesomeDay.tuesday.value;
      case AlarmRepeatType.atWednesday:
        return AwesomeDay.wednesday.value;
      case AlarmRepeatType.atThursday:
        return AwesomeDay.thursday.value;
      case AlarmRepeatType.atFriday:
        return AwesomeDay.friday.value;
    }
  }

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
