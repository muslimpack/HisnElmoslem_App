import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/models/alarm.dart';

import 'notification_manager.dart';

AlarmManager alarmManager = AlarmManager();

class AlarmManager {
  alarmState({required DbAlarm dbAlarm}) {
    if (dbAlarm.isActive == 1) {
      localNotifyManager.showCustomNotification(
          title: "تم تفعيل منبه ${dbAlarm.title}", payload: '');
      switch (dbAlarm.repeatType) {
        case "Daily":
          localNotifyManager.addCustomDailyReminder(
              channelName: "تنبيهات الأذكار",
              id: dbAlarm.id,
              title: dbAlarm.title,
              body: dbAlarm.body,
              time: Time(dbAlarm.hour, dbAlarm.minute, 0),
              payload: (dbAlarm.id).toString());
          break;
        case "AtSaturday":
          localNotifyManager.addCustomWeeklyReminder(
            channelName: "تنبيهات الأذكار",
            id: dbAlarm.id,
            title: dbAlarm.title,
            body: dbAlarm.body,
            time: Time(dbAlarm.hour, dbAlarm.minute, 0),
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
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
            payload: (dbAlarm.id).toString(),
            day: Day.friday,
          );
          break;
      }
      // if (dbAlarm.repeatType == "Daily") {
      //   localNotifyManager.customDailyReminder(
      //       channelName: "تنبيهات الأذكار",
      //       id: dbAlarm.id,
      //       title: dbAlarm.title,
      //       body: dbAlarm.body,
      //       time: Time(dbAlarm.hour, dbAlarm.minute, 0),
      //       payload: (dbAlarm.id).toString());
      // }
    } else if (dbAlarm.isActive == 0) {
      localNotifyManager.showCustomNotification(
          title: "تم الغاء منبه ${dbAlarm.title}", payload: '');
      localNotifyManager.cancelNotificationById(id: dbAlarm.id);
    }
  }
}
