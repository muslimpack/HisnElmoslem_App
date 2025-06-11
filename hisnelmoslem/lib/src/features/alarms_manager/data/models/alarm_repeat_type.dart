import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
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

  String getUserFriendlyName(BuildContext context) {
    switch (this) {
      case AlarmRepeatType.daily:
        return S.of(context).daily;
      case AlarmRepeatType.atSaturday:
        return S.of(context).everySaturday;
      case AlarmRepeatType.atSunday:
        return S.of(context).everySunday;
      case AlarmRepeatType.atMonday:
        return S.of(context).everyMonday;
      case AlarmRepeatType.atTuesday:
        return S.of(context).everyTuesday;
      case AlarmRepeatType.atWednesday:
        return S.of(context).everyWednesday;
      case AlarmRepeatType.atThursday:
        return S.of(context).everyThursday;
      case AlarmRepeatType.atFriday:
        return S.of(context).everyFriday;
    }
  }
}
