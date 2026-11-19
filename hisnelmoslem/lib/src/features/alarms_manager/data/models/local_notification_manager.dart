import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarms_repo.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/permission_dialog.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_alarm_scheduler.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';
import 'package:path/path.dart' as path;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class LocalNotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _settingsChannel = MethodChannel('notification_settings_channel');

  /// Windows can only schedule one-shot toasts, so repeating alarms are expanded
  /// into the next few occurrences (re-planned on every app launch).
  /// Occurrence `k` uses id `id + k * windowsOccurrenceStride`.
  static const int windowsOccurrenceStride = 10000000;
  static const int _windowsDailyOccurrences = 14;
  static const int _windowsWeeklyOccurrences = 8;

  NotificationResponse? launchNotificationResponse;
  bool _isDialogShowing = false;

  /// Android and iOS ask the user at runtime; desktop has no such permission.
  bool get _needsRuntimePermission => PlatformExtension.isPhone;

  Future<void> _ready = Future<void>.value();

  /// Completes when [init] has finished. Anything that touches the plugin or the time
  /// zone must wait for it, because startup does not (see `initServices`).
  Future<void> ensureReady() => _ready;

  /// Starts the setup and returns the same future [ensureReady] gives, so the caller
  /// may leave it running instead of holding up the first frame.
  Future<void> init() => _ready = _init();

  Future<void> _init() async {
    try {
      await _configureLocalTimeZone();

      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

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

      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        launchNotificationResponse = notificationAppLaunchDetails!.notificationResponse;
      }
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

  /// Zone name and UTC offset the alarms were last planned with.
  String? _timeZoneSignature;

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    await _applyDeviceTimeZone();
  }

  Future<void> _applyDeviceTimeZone() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    _timeZoneSignature = '${timezoneInfo.identifier}|${DateTime.now().timeZoneOffset.inMinutes}';
  }

  /// Re-reads the device time zone and returns whether it, or its UTC offset
  /// (a DST change), differs from what the alarms were planned with.
  ///
  /// Scheduled alarms keep the wall-clock time they were planned with, so they
  /// must be planned again when this returns `true`.
  Future<bool> refreshTimeZone() async {
    await _ready;
    final before = _timeZoneSignature;
    try {
      await _applyDeviceTimeZone();
    } catch (e) {
      hisnPrint(e);
      return false;
    }
    return before != null && before != _timeZoneSignature;
  }

  Future<bool> requestPermissionWithDialog({bool triggerOnStartup = false}) async {
    await _ready;
    if (!_needsRuntimePermission) return true;
    if (_isDialogShowing) return false;

    /// if the user ignored the notification permission, don't show the dialog
    final appSettingsRepo = sl<AppSettingsRepo>();
    if (appSettingsRepo.ignoreNotificationPermission) return false;

    if (triggerOnStartup) {
      /// if the user has no alarms, don't show the dialog
      final hasAlarms = await _hasAnyActiveAlarms();
      if (!hasAlarms) return false;
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    bool notificationsAllowed = false;
    bool exactAlarmsAllowed = true;

    if (Platform.isAndroid) {
      notificationsAllowed = await androidPlugin?.areNotificationsEnabled() ?? false;
      exactAlarmsAllowed = await androidPlugin?.canScheduleExactNotifications() ?? true;
    } else if (Platform.isIOS) {
      notificationsAllowed = await isPermissionGranted();
      exactAlarmsAllowed = true;
    }

    if (notificationsAllowed && exactAlarmsAllowed) return true;

    final BuildContext? context = App.navigatorKey.currentContext;
    if (context == null || !context.mounted) return false;

    _isDialogShowing = true;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PermissionDialog(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        );
      },
    );
    _isDialogShowing = false;

    return result ?? false;
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
    if (!PlatformExtension.supportsScheduledReminders) return;
    await _ready;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationById({required int id}) async {
    if (!PlatformExtension.supportsScheduledReminders) return;
    await _ready;
    await flutterLocalNotificationsPlugin.cancel(id: id);
    if (Platform.isWindows) {
      for (var k = 1; k < _windowsDailyOccurrences; k++) {
        await flutterLocalNotificationsPlugin.cancel(id: id + k * windowsOccurrenceStride);
      }
    }
  }

  NotificationDetails _buildNotificationDetails(
    NotifyChannel channel,
    String? title,
    String? body,
  ) {
    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body ?? '',
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.key,
        channel.name,
        channelDescription: channel.description,
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
    await _ready;
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.inApp,
        title,
        body,
      ),
      payload: payload,
    );
  }

  /// Show Notification App Open
  Future<void> appOpenNotification() async {
    await _ready;
    final scheduleNotificationDateTime = _addDays(tz.TZDateTime.now(tz.local), 3);

    await _safeZonedSchedule(
      id: 1000,
      title: SX.current.haveNotOpenedAppLongTime,
      body: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      scheduledDate: scheduleNotificationDateTime,
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled,
        SX.current.haveNotOpenedAppLongTime,
        'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      ),
      payload: "2",
    );
  }

  Future<void> _safeZonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (!PlatformExtension.supportsScheduledReminders) return;
    if (Platform.isWindows) {
      await _scheduleWindowsWindow(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      return;
    }
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (e) {
      hisnPrint("Error scheduling exact alarm, falling back to inexact: $e");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    }
  }

  Future<void> _scheduleWindowsWindow({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required String? payload,
    required DateTimeComponents? matchDateTimeComponents,
  }) async {
    final bool weekly = matchDateTimeComponents == DateTimeComponents.dayOfWeekAndTime;
    final bool repeating = matchDateTimeComponents != null;
    final int count = !repeating
        ? 1
        : weekly
        ? _windowsWeeklyOccurrences
        : _windowsDailyOccurrences;
    final int stepDays = weekly ? 7 : 1;

    try {
      // Drop what was planned before so a re-plan never duplicates toasts.
      await cancelNotificationById(id: id);
      var date = scheduledDate;
      for (var k = 0; k < count; k++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id + k * windowsOccurrenceStride,
          title: title,
          body: body,
          scheduledDate: date,
          notificationDetails: notificationDetails,
          // Required by the API, ignored on Windows.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
        date = _addDays(date, stepDays);
        // The Windows calls are synchronous; let the UI draw between them.
        await Future<void>.delayed(Duration.zero);
      }
    } catch (e) {
      hisnPrint("Error scheduling Windows notification $id: $e");
    }
  }

  /// Adds calendar days and keeps the wall-clock time.
  ///
  /// `TZDateTime.add(Duration(days: n))` adds absolute hours, so across a DST
  /// change the reminder would land an hour early or late.
  tz.TZDateTime _addDays(tz.TZDateTime date, int days) {
    return tz.TZDateTime(tz.local, date.year, date.month, date.day + days, date.hour, date.minute);
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
      scheduledDate = _addDays(scheduledDate, 1);
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, Time time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = _addDays(scheduledDate, 1);
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
    bool requestPermission = true,
  }) async {
    await _ready;
    if (requestPermission) {
      await requestPermissionWithDialog();
    }
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekdayAndTime(weekday, time),
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled,
        title,
        body,
      ),
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
    bool requestPermission = true,
  }) async {
    await _ready;
    if (requestPermission) {
      await requestPermissionWithDialog();
    }
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: _buildNotificationDetails(
        NotificationsChannels.scheduled,
        title,
        body,
      ),
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
    /// go to a custom title if clicked (payload `custom:<titleId>`)
    else if (CustomAlarmScheduler.titleIdFromPayload(payload) case final int customTitleId) {
      context.push(ZikrViewerScreen.custom(customTitleId: customTitleId));
    }
    /// go to zikr page if clicked
    else {
      final int? pageIndex = int.tryParse(payload);
      if (pageIndex != null) {
        context.push(ZikrViewerScreen(index: pageIndex));
      }
    }
  }

  Future<void> handleLaunchNotification() async {
    await _ready;
    if (launchNotificationResponse != null) {
      final String? payload = launchNotificationResponse!.payload;
      if (payload != null && payload.isNotEmpty) {
        onNotificationClick(payload);
      }
      launchNotificationResponse = null;
    }
  }

  Future<bool> isPermissionGranted() async {
    await _ready;
    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final permissions = await iosPlugin?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    // Windows and other desktops have no runtime permission.
    return true;
  }

  /// Opens the system page where the user can re-enable notifications.
  Future<void> openNotificationSettings() async {
    try {
      if (Platform.isAndroid) {
        await _settingsChannel.invokeMethod<void>('openNotificationSettings');
      } else if (Platform.isIOS) {
        await launchUrl(Uri.parse('app-settings:'));
      }
    } catch (e) {
      hisnPrint(e);
    }
  }

  /// Asks for the notification permission, or sends the user to settings when
  /// the system will no longer show its prompt.
  ///
  /// Returns whether notifications are enabled afterwards.
  Future<bool> requestNotificationPermission() async {
    await _ready;
    final repo = sl<AppSettingsRepo>();
    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidPlugin?.requestNotificationsPermission();
      if (granted == true) return true;
      // Denied (possibly permanently) or disabled in settings: the system prompt
      // may not appear again, so offer the settings page.
      if (await isPermissionGranted()) return true;
      if (repo.notificationPermissionRequested) await openNotificationSettings();
      await repo.changeNotificationPermissionRequested(value: true);
      return false;
    } else if (Platform.isIOS) {
      // iOS shows its prompt only once. Afterwards a refusal can only be undone in settings.
      if (repo.notificationPermissionRequested) {
        await openNotificationSettings();
        return false;
      }
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final bool? granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await repo.changeNotificationPermissionRequested(value: true);
      return granted ?? false;
    }
    return true;
  }

  Future<bool> _hasAnyActiveAlarms() async {
    final alarmsRepo = sl<AlarmsRepo>();
    final alarmDatabaseHelper = sl<AlarmDatabaseHelper>();

    if (alarmsRepo.isCaveAlarmEnabled) return true;
    if (alarmsRepo.isFastAlarmEnabled) return true;

    final alarms = await alarmDatabaseHelper.getAlarms();
    if (alarms.any((alarm) => alarm.isActive)) return true;

    final customAlarms = await sl<CustomAzkarRepo>().getAlarms();
    if (customAlarms.any((alarm) => alarm.isActive)) return true;

    return false;
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
  static NotifyChannel get inApp => NotifyChannel(
    key: 'in_app_notification',
    name: SX.current.channelInAppName,
    description: SX.current.channelInAppNameDesc,
  );
  static NotifyChannel get scheduled => NotifyChannel(
    key: 'scheduled_channel',
    name: SX.current.channelScheduledName,
    description: SX.current.channelScheduledNameDesc,
  );
}
