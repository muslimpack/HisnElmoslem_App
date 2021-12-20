/*
I get this code from
Youtube| Flutter: Push Notification (Local, schedule, repeat, daily, weekly)
URL| https://www.youtube.com/watch?v=KlgVI4dQC4E
 */

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSetting;

  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();

  NotificationManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    intializePlatform();
  }

  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  intializePlatform() {
    var initSettingAndroid =
    AndroidInitializationSettings('app_notification_icon');
    var initSettingIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        defaultPresentSound: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceiveNotification notification = ReceiveNotification(
              id: id, title: title, body: body, payload: payload);
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
        onSelectNotification: (String payload) async {
          onNotificationClick(payload);
        });
  }

  Future<void> showNotification() async {
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel =
    IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    await flutterLocalNotificationsPlugin.show(
        0, 'Test Title', 'Test Body', platformChannel,
        payload: 'New Payload');
  }

  Future<void> scheduleNotification() async {
    var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 1));
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'schedule Test Title',
      'schedule Test Body',
      scheduleNotificationDateTime,
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> repeatNotification() async {
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Repeat Test Title',
      'Repeat Test Body',
      RepeatInterval.everyMinute,
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> showDailyAtTimeNotification() async {
    var time = Time(24, 12, 0);
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Daily Test Title ${time.hour}-${time.minute}-${time.second}',
      'Daily Test Body',
      time,
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> showWeeklyAtDayTimeNotification() async {
    var time = Time(24, 12, 0);
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      'Weekly Test Title ${time.hour}-${time.minute}-${time.second}',
      'Weekly Test Body',
      Day.friday,
      time,
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void>  customDailyReminder({@required String channelName,@required int id,@required String title,String body,@required Time time,String payload}) async {
    //Time time = Time(24, 12, 0);
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      //timeoutAfter: 5000,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      title,
      body,
      time,
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> customWeeklyReminder({@required String channelName,@required int id,int showTime = 5000,@required String title,String body,String payload,@required Time time,@required Day day}) async {
    //var time = Time(24, 12, 0);
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      channelName,
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      //timeoutAfter: showTime,
      enableLights: true,
    );

    var iosChannel = IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    //day: Day.Friday
    //time: Time(24,00,0)
    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      title,
      body,
      day,
      time,
      platformChannel,
      payload: payload,
    );
  }
  Future<void> customShowNotification({@required int id,@required String title,int showTime = 5000,String body,String payload}) async {
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'الإشعارات داخل التطبيق',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //Add if u need
      //sound: RawResourceAndroidNotificationSound('notification_sound.mp3'),
      //icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: showTime,
      enableLights: true,
    );

    var iosChannel =
    IOSNotificationDetails(/*sound: 'notification_sound.mp3'*/);
    var platformChannel =
    NotificationDetails(android: androidChannel, iOS: iosChannel);

    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannel,
        payload: payload);
  }

}

NotificationManager localNotifyManager = NotificationManager.init();

class ReceiveNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceiveNotification(
      {@required this.id,
        @required this.title,
        @required this.body,
        @required this.payload});
}
