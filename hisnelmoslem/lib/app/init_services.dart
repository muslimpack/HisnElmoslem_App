import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/utils/migration/migration.dart';
import 'package:hisnelmoslem/core/utils/notification_manager.dart';

Future<void> initServices() async {
  await GetStorage.init();
  await Migration.start();
  await awesomeNotificationManager.init();
  await localNotifyManager.cancelAllNotifications();
  await awesomeNotificationManager.appOpenNotification();
  await alarmManager.checkAllAlarmsInDb();
}
