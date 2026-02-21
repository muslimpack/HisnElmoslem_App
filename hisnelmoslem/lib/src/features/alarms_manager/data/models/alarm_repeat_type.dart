import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

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
        return DateTime.saturday;
      case AlarmRepeatType.atSunday:
        return DateTime.sunday;
      case AlarmRepeatType.atMonday:
        return DateTime.monday;
      case AlarmRepeatType.atTuesday:
        return DateTime.tuesday;
      case AlarmRepeatType.atWednesday:
        return DateTime.wednesday;
      case AlarmRepeatType.atThursday:
        return DateTime.thursday;
      case AlarmRepeatType.atFriday:
        return DateTime.friday;
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
