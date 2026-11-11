import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';

/// Lets the existing alarm editor dialog (which edits a [DbAlarm]) be reused.
extension CustomAlarmToDbAlarm on CustomAlarm {
  DbAlarm toDbAlarm(String titleName) {
    return DbAlarm(
      id: id,
      titleId: titleId,
      title: titleName,
      body: body,
      repeatType: repeatType,
      hour: hour,
      minute: minute,
      isActive: isActive,
    );
  }
}

extension DbAlarmToCustomAlarm on DbAlarm {
  CustomAlarm toCustomAlarm() {
    return CustomAlarm(
      id: id,
      titleId: titleId,
      body: body,
      repeatType: repeatType,
      hour: hour,
      minute: minute,
      isActive: isActive,
    );
  }
}
