import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/awesome_day.dart';
import 'package:hisnelmoslem/app/data/models/alarm.dart';
import 'package:hisnelmoslem/app/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';

AlarmManager alarmManager = AlarmManager();

class AlarmManager {
  Future<void> alarmState(
      {required DbAlarm dbAlarm, bool showMsg = true}) async {
    if (dbAlarm.isActive) {
      // Get.snackbar("رسالة", "تفعيل منبه ${dbAlarm.title}",
      //     duration: const Duration(seconds: 1),
      //     icon: Image.asset("assets/images/app_icon.png"));
      if (showMsg) {
        getSnackbar(message: "${"activate".tr} | ${dbAlarm.title}");
      }
      switch (dbAlarm.repeatType) {
        case "Daily":
          await awesomeNotificationManager.addCustomDailyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
          );
          break;
        case "AtSaturday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.saturday.value,
          );
          break;
        case "AtSunday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.sunday.value,
          );
          break;
        case "AtMonday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(
              dbAlarm.hour,
              dbAlarm.minute,
            ),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.monday.value,
          );
          break;
        case "AtTuesday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.tuesday.value,
          );
          break;
        case "AtWednesday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.wednesday.value,
          );
          break;
        case "AtThursday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.thursday.value,
          );
          break;
        case "AtFriday":
          await awesomeNotificationManager.addCustomWeeklyReminder(
            id: dbAlarm.titleId,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute),
            payload: (dbAlarm.titleId).toString(),
            weekday: AwesomeDay.friday.value,
          );
          break;
      }
    } else if (!dbAlarm.isActive) {
      // Get.snackbar("رسالة", "الغاء تفعيل منبه ${dbAlarm.title}",
      //     duration: const Duration(seconds: 1),
      //     icon: Image.asset("assets/images/app_icon.png"));
      if (showMsg) {
        getSnackbar(message: "${"deactivate".tr} | ${dbAlarm.title}");
      }

      awesomeNotificationManager.cancelNotificationById(id: dbAlarm.titleId);
    }
  }

  Future<void> checkAllAlarmsInDb() async {
    final box = GetStorage();
    final bool isAwesomeSet = box.read<bool>('is_awesome_set') ?? false;
    if (!isAwesomeSet) {
      hisnPrint("Setup Awesome from database ....");
      await alarmDatabaseHelper.getAlarms().then((value) {
        final List<DbAlarm> alarms = value;
        for (var i = 0; i < alarms.length; i++) {
          final DbAlarm alarm = alarms[i];
          alarmState(dbAlarm: alarm, showMsg: false);
        }
      });
      box.write('is_awesome_set', true);
    }
  }
}
