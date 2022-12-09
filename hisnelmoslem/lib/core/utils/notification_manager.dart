/*
I get this code from
Youtube| Flutter: Push Notification (Local, schedule, repeat, daily, weekly)
URL| https://www.youtube.com/watch?v=KlgVI4dQC4E
 */

import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import '../../app/data/models/received_notification.dart';

NotificationManager localNotifyManager = NotificationManager.init();

class NotificationManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late InitializationSettings initSetting;

  BehaviorSubject<ReceivedNotification>
      get didReceiveLocalNotificationSubject =>
          BehaviorSubject<ReceivedNotification>();

  NotificationManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatform();
  }

  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  initializePlatform() {
    var initSettingAndroid =
        const AndroidInitializationSettings('app_notification_icon');
    var initSettingIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        defaultPresentSound: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceivedNotification notification = ReceivedNotification(
              id: id, title: title!, body: body!, payload: payload!);
          didReceiveLocalNotificationSubject.add(notification);
        });

    initSetting = InitializationSettings(
        android: initSettingAndroid, iOS: initSettingIOS);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String? payload) async {
      onNotificationClick(payload);
    });
  }

  // Future<void> cancelNotificationById({required int id}) async {
  //   await flutterLocalNotificationsPlugin.cancel(id);
  // }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

// Future<void> addCustomDailyReminder(
//     {required String channelName,
//     required int id,
//     required String title,
//     String? body,
//     required Time time,
//     required String payload}) async {
//   //Time time = Time(24, 12, 0);
//   var androidChannel = AndroidNotificationDetails(
//     'CHANNEL_ID', channelName,

//     importance: Importance.max,
//     priority: Priority.high,
//     playSound: true,
//     //Add if u need
//     //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
//     icon: '@mipmap/ic_launcher',
//     largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//     //timeoutAfter: 5000,
//     enableLights: true,
//   );

//   var iosChannel =
//       const IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
//   var platformChannel =
//       NotificationDetails(android: androidChannel, iOS: iosChannel);

//   // ignore: deprecated_member_use
//   await flutterLocalNotificationsPlugin.showDailyAtTime(
//     id,
//     title,
//     body,
//     time,
//     platformChannel,
//     payload: payload,
//   );
// }

// Future<void> addCustomWeeklyReminder(
//     {required String channelName,
//     required int id,
//     int showTime = 5000,
//     required String title,
//     String? body,
//     required String payload,
//     required Time time,
//     required Day day}) async {
//   //var time = Time(24, 12, 0);
//   var androidChannel = AndroidNotificationDetails(
//     'CHANNEL_ID',
//     channelName,

//     importance: Importance.max,
//     priority: Priority.high,
//     playSound: true,
//     //Add if u need
//     //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
//     icon: '@mipmap/ic_launcher',
//     largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//     //timeoutAfter: showTime,
//     enableLights: true,
//   );

//   var iosChannel =
//       const IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
//   var platformChannel =
//       NotificationDetails(android: androidChannel, iOS: iosChannel);

//   //day: Day.Friday
//   //time: Time(24,00,0)
//   // ignore: deprecated_member_use
//   await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
//     id,
//     title,
//     body,
//     day,
//     time,
//     platformChannel,
//     payload: payload,
//   );
// }

// Future<void> appOpenNotification() async {
//   var scheduleNotificationDateTime =
//       DateTime.now().add(const Duration(days: 3));
//   var androidChannel = const AndroidNotificationDetails(
//     'CHANNEL_ID',
//     'إشعار عدم فتح التطبيق',

//     importance: Importance.max,
//     priority: Priority.high,
//     playSound: true,
//     //Add if u need
//     //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
//     icon: '@mipmap/ic_launcher',
//     largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//     enableLights: true,
//   );

//   var iosChannel =
//       const IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
//   var platformChannel =
//       NotificationDetails(android: androidChannel, iOS: iosChannel);

//   // ignore: deprecated_member_use
//   await flutterLocalNotificationsPlugin.schedule(
//     1000,
//     'لم تفتح التطبيق منذ فنرة 😀',
//     'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
//     scheduleNotificationDateTime,
//     platformChannel,
//     payload: '2',
//   );
// }
}
