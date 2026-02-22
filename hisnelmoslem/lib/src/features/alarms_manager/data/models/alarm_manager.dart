// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';

class AlarmManager {
  final LocalNotificationManager localNotificationManager;

  AlarmManager(this.localNotificationManager);

  Future<void> alarmState({
    required DbAlarm dbAlarm,
    bool showMsg = true,
  }) async {
    if (dbAlarm.isActive) {
      if (showMsg) {
        showToast(msg: "${SX.current.activate}: ${dbAlarm.title}");
      }

      if (dbAlarm.repeatType == AlarmRepeatType.daily) {
        await localNotificationManager.addCustomDailyReminder(
          id: dbAlarm.titleId,
          title: dbAlarm.title,
          body: dbAlarm.body,
          time: Time(dbAlarm.hour, dbAlarm.minute),
          payload: dbAlarm.titleId.toString(),
        );
      } else {
        await localNotificationManager.addCustomWeeklyReminder(
          id: dbAlarm.titleId,
          title: dbAlarm.title,
          body: dbAlarm.body,
          time: Time(dbAlarm.hour, dbAlarm.minute),
          payload: dbAlarm.titleId.toString(),
          weekday: dbAlarm.repeatType.getWeekDay(),
        );
      }
    } else {
      if (showMsg) {
        showToast(msg: "${SX.current.deactivate}: ${dbAlarm.title}");
      }

      await localNotificationManager.cancelNotificationById(
        id: dbAlarm.titleId,
      );
    }
  }

  Future<void> checkAllAlarmsInDb() async {
    hisnPrint("Setup Flutter Local Notifications from database ....");
    final alarms = await sl<AlarmDatabaseHelper>().getAlarms();
    for (var i = 0; i < alarms.length; i++) {
      final DbAlarm alarm = alarms[i];
      await alarmState(dbAlarm: alarm, showMsg: false);
    }
    // Note: We don't write the flag here.
    // We write it in AlarmsBloc after migrating Fast and Cave alarms.
  }
}
