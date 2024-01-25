import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/managers/alarm_manager.dart';
import 'package:hisnelmoslem/src/core/managers/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/core/managers/notification_manager.dart';
import 'package:hisnelmoslem/src/core/shared/migration/migration.dart';
import 'package:hisnelmoslem/src/core/utils/print.dart';

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await GetStorage.init();
    await Migration.start();
    await awesomeNotificationManager.init();
    await alarmManager.checkAllAlarmsInDb();
    await localNotifyManager.cancelAllNotifications();
    await awesomeNotificationManager.appOpenNotification();
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  } catch (e) {
    hisnPrint(e);
  }
}
