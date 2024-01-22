import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/managers/alarm_manager.dart';
import 'package:hisnelmoslem/src/core/managers/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/core/managers/notification_manager.dart';
import 'package:hisnelmoslem/src/core/shared/migration/migration.dart';
import 'package:hisnelmoslem/src/core/utils/print.dart';

Future<void> initServices() async {
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
