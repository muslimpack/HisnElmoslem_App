import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/utils/migration/migration.dart';
import 'package:hisnelmoslem/core/utils/notification_manager.dart';

Future<void> initServices() async {
  try {
    await GetStorage.init();
    await Migration.start();
    await awesomeNotificationManager.init();
    await alarmManager.checkAllAlarmsInDb();
    await localNotifyManager.cancelAllNotifications();
    await awesomeNotificationManager.appOpenNotification();
  } catch (e) {
    hisnPrint(e);
  }
  AwesomeNotifications().initialize(
    'resource://drawable/res_hisnelmoslem',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
  );
}
