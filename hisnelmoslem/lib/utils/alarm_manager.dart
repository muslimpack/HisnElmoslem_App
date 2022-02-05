import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/models/alarm.dart';

import '../shared/functions/get_snackbar.dart';
import 'notification_manager.dart';

AlarmManager alarmManager = AlarmManager();

class AlarmManager {
  alarmState({required DbAlarm dbAlarm}) {
    if (dbAlarm.isActive == 1) {
      // Get.snackbar("رسالة", "تم تفعيل منبه ${dbAlarm.title}",
      //     duration: const Duration(seconds: 1),
      //     icon: Image.asset("assets/images/app_icon.png"));
      getSnackbar(message: "تم تفعيل منبه ${dbAlarm.title}");
      switch (dbAlarm.repeatType) {
        case "Daily":
          localNotifyManager.addCustomDailyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
          );
          break;
        case "AtSaturday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.saturday,
          );
          break;
        case "AtSunday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.sunday,
          );
          break;
        case "AtMonday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.monday,
          );
          break;
        case "AtTuesday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.tuesday,
          );
          break;
        case "AtWednesday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.wednesday,
          );
          break;
        case "AtThursday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.thursday,
          );
          break;
        case "AtFriday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.titleId).toString(),
            day: Day.friday,
          );
          break;
      }
    } else if (dbAlarm.isActive == 0) {
      // Get.snackbar("رسالة", "تم الغاء منبه ${dbAlarm.title}",
      //     duration: const Duration(seconds: 1),
      //     icon: Image.asset("assets/images/app_icon.png"));
      getSnackbar(message: "تم الغاء منبه ${dbAlarm.title}");

      localNotifyManager.cancelNotificationById(id: dbAlarm.id);
    }
  }
}
