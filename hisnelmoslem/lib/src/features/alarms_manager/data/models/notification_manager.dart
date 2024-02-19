/*
I get this code from
Youtube| Flutter: Push Notification (Local, schedule, repeat, daily, weekly)
URL| https://www.youtube.com/watch?v=KlgVI4dQC4E
 */

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

NotificationManager localNotifyManager = NotificationManager.init();

class NotificationManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
