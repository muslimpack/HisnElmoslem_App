import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';
import 'package:path/path.dart' as path;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      final bool? isAllowed = await requestPermissionWithDialog();

      if (isAllowed == null || !isAllowed) return;

      await _configureLocalTimeZone();

      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings();

      final WindowsInitializationSettings windowsInitializationSettings =
          _windowsInitializationSettings();

      final InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
        windows: windowsInitializationSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      await appOpenNotification();
    } catch (e) {
      hisnPrint(e);
    }
  }

  WindowsInitializationSettings _windowsInitializationSettings() {
    String? iconPath;
    if (Platform.isWindows) {
      final String exePath = Platform.resolvedExecutable;
      final String appDir = path.dirname(exePath);
      iconPath = path.join(
        appDir,
        'data',
        'flutter_assets',
        'assets/images/app_icon.png',
      );
      if (!File(iconPath).existsSync()) {
        iconPath = null;
      }
    }

    return WindowsInitializationSettings(
      appName: SX.appName,
      appUserModelId: 'com.hassaneltantawy.hisnelmoslem',
      //run `[guid]::NewGuid()` on windows
      guid: '82fd58ee-c707-40ba-b2f8-799d8cb40e12',
      iconPath: iconPath,
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  }

  Future<bool?> requestPermissionWithDialog() async {
    final BuildContext? context = App.navigatorKey.currentContext;
    if (context == null) return null;

    final appSettingsRepo = sl<AppSettingsRepo>();
    if (appSettingsRepo.ignoreNotificationPermission) return null;

    bool isAllowed = false;
    if (Platform.isAndroid) {
      isAllowed =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    } else if (Platform.isIOS) {
      // iOS permissions are implicitly handled via requestPermissions below, but we assume true initially if already accepted in the past
    }

    if (isAllowed) return true;

    if (!context.mounted) return null;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(SX.current.allowNotifications),
          content: Text(SX.current.notificationPermissionRequired),
          actions: [
            TextButton(
              child: Text(SX.current.ignoreNotificationPermission),
              onPressed: () {
                appSettingsRepo.changeIgnoreNotificationPermissionStatus(
                  value: true,
                );
                Navigator.pop<bool>(context, false);
              },
            ),
            TextButton(
              child: Text(SX.current.later),
              onPressed: () {
                Navigator.pop<bool>(context, false);
              },
            ),
            FilledButton(
              child: Text(SX.current.allow),
              onPressed: () {
                Navigator.pop<bool>(context, true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      return true;
    }

    return false;
  }

  @pragma("vm:entry-point")
  static Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    hisnPrint("actionStream: $payload");

    if (payload != null && payload.isNotEmpty) {
      onNotificationClick(payload);
    } else {
      hisnPrint("actionStream: Else");
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationById({required int id}) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  NotificationDetails _buildNotificationDetails(
    String channelId,
    String channelName,
    String channelDesc,
    String? title,
    String? body,
  ) {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
          body ?? '',
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
        );

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigTextStyleInformation,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Show Notification
  Future<void> showCustomNotification({
    required String title,
    String? body,
    required String payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.inApp.key,
        NotificationsChannels.inApp.name,
        NotificationsChannels.inApp.description,
        title,
        body,
      ),
      payload: payload,
    );
  }

  /// Show Notification App Open
  Future<void> appOpenNotification() async {
    final scheduleNotificationDateTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(days: 3));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1000,
      title: SX.current.haveNotOpenedAppLongTime,
      body: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      scheduledDate: scheduleNotificationDateTime,
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled.key,
        NotificationsChannels.scheduled.name,
        NotificationsChannels.scheduled.description,
        SX.current.haveNotOpenedAppLongTime,
        'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "2",
    );
  }

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, Time time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Add weekly notification
  Future<void> addCustomWeeklyReminder({
    required int id,
    required String title,
    String? body,
    required String payload,
    required Time time,
    required int weekday,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekdayAndTime(weekday, time),
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled.key,
        NotificationsChannels.scheduled.name,
        NotificationsChannels.scheduled.description,
        title,
        body,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  /// Add Daily notification
  Future<void> addCustomDailyReminder({
    required int id,
    required String title,
    String? body,
    required Time time,
    required String payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled.key,
        NotificationsChannels.scheduled.name,
        NotificationsChannels.scheduled.description,
        title,
        body,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  ///
  static void onNotificationClick(String payload) {
    final context = App.navigatorKey.currentState?.context;
    if (context == null) return;

    /// go to quran page if clicked
    if (payload == "الكهف") {
      context.push(const QuranReadScreen(surahName: SurahNameEnum.alKahf));
    }
    /// ignore constant alarms if clicked
    else if (payload == "555" || payload == "666") {
    }
    /// go to zikr page if clicked
    else {
      final int? pageIndex = int.tryParse(payload);
      if (pageIndex != null) {
        context.push(ZikrViewerScreen(index: pageIndex));
      }
    }
  }
}

class Time {
  final int hour;
  final int minute;
  Time(this.hour, [this.minute = 0]);
}

class NotifyChannel {
  final String key;
  final String name;
  final String description;
  NotifyChannel({
    required this.key,
    required this.name,
    required this.description,
  });
}

class NotificationsChannels {
  static NotifyChannel inApp = NotifyChannel(
    key: 'in_app_notification',
    name: SX.current.channelInAppName,
    description: SX.current.channelInAppNameDesc,
  );
  static NotifyChannel scheduled = NotifyChannel(
    key: 'scheduled_channel',
    name: SX.current.channelScheduledName,
    description: SX.current.channelScheduledNameDesc,
  );
}
