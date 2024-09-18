import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_page.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_card_mode_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_page_mode_screen.dart';

class AwesomeNotificationManager {
  Future<void> init() async {
    try {
      await AwesomeNotifications()
          .isNotificationAllowed()
          .then((isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });

      await AwesomeNotifications().initialize(
        /// using null here mean it will use app icon for notification icon
        /// If u want use custom one replace null with below
        /// 'resource://drawable/res_app_icon',
        null,
        [
          NotificationChannel(
            channelKey: NotificationsChannels.inApp.key,
            channelName: NotificationsChannels.inApp.name,
            channelDescription: NotificationsChannels.inApp.description,
            defaultColor: Colors.teal,
            importance: NotificationImportance.High,
            playSound: true,
          ),
          NotificationChannel(
            channelKey: NotificationsChannels.scheduled.key,
            channelName: NotificationsChannels.scheduled.name,
            channelDescription: NotificationsChannels.scheduled.description,
            defaultColor: Colors.teal,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
          ),
        ],
        debug: true,
      );
    } catch (e) {
      hisnPrint(e);
    }
  }

  Future listen() async {
    await AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final List<String?> payloadsList = receivedAction.payload!.values.toList();
    final String? payload = payloadsList[0];
    hisnPrint("actionStream: $payload");

    try {
      final int currentBadgeCount =
          await AwesomeNotifications().getGlobalBadgeCounter();
      if (currentBadgeCount > 5) {
        await AwesomeNotifications().resetGlobalBadge();
      } else {
        await AwesomeNotifications().decrementGlobalBadgeCounter();
      }
    } catch (e) {
      hisnPrint(e);
    }

    if (payload!.isNotEmpty) {
      onNotificationClick(payload);
    } else {
      hisnPrint("actionStream: Else");
    }
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  Future<void> cancelNotificationById({
    required int id,
  }) async {
    await AwesomeNotifications().cancelSchedule(id);
  }

  /// Show Notification
  Future<void> showCustomNotification({
    required String title,
    String? body,
    required String payload,
  }) async {
    // int id = createUniqueId();c
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: NotificationsChannels.inApp.key,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        payload: {'Open': payload},
        fullScreenIntent: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'Dismiss',
          label: S.current.dismiss,
          actionType: ActionType.DisabledAction,
        ),
        NotificationActionButton(
          key: 'Start',
          label: S.current.start,
        ),
      ],
    );
  }

  /// Show Notification
  Future<void> appOpenNotification() async {
    final scheduleNotificationDateTime =
        DateTime.now().add(const Duration(days: 3));
    // int id = createUniqueId();c
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1000,
        channelKey: NotificationsChannels.scheduled.key,
        title: S.current.haveNotOpenedAppLongTime,
        body: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
        notificationLayout: NotificationLayout.BigText,
        payload: {'Open': "2"},
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduleNotificationDateTime,
        allowWhileIdle: true,
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }

  /// Add weekly notification
  Future<void> addCustomWeeklyReminder({
    required int id,
    required String title,
    String? body,
    required String payload,
    required Time time,
    int? weekday,
    bool needToOpen = true,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: NotificationsChannels.scheduled.key,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        payload: {'Open': payload},
      ),
      schedule: NotificationCalendar(
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        allowWhileIdle: true,
        repeats: true,
        weekday: weekday,
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
      ),
      actionButtons: needToOpen
          ? [
              NotificationActionButton(
                key: 'Dismiss',
                label: S.current.dismiss,
                actionType: ActionType.DisabledAction,
              ),
              NotificationActionButton(
                key: 'Start',
                label: S.current.start,
              ),
            ]
          : [
              NotificationActionButton(
                key: 'Dismiss',
                label: S.current.dismiss,
                actionType: ActionType.DisabledAction,
              ),
            ],
    );
  }

  /// Add Daily notification
  Future<void> addCustomDailyReminder({
    required int id,
    required String title,
    String? body,
    required Time time,
    required String payload,
    bool needToOpen = true,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: NotificationsChannels.scheduled.key,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        payload: {'Open': payload},
      ),
      schedule: NotificationCalendar(
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        allowWhileIdle: true,
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
      actionButtons: needToOpen
          ? [
              NotificationActionButton(
                key: 'Dismiss',
                label: S.current.dismiss,
                actionType: ActionType.DisabledAction,
              ),
              NotificationActionButton(
                key: 'Start',
                label: S.current.start,
              ),
            ]
          : [
              NotificationActionButton(
                key: 'Dismiss',
                label: S.current.dismiss,
                actionType: ActionType.DisabledAction,
              ),
            ],
    );
  }

  ///
  static void onNotificationClick(String payload) {
    final context = App.navigatorKey.currentState?.context;
    if (context == null) return;

    /// go to quran page if clicked
    if (payload == "الكهف") {
      transitionAnimation.fromBottom2Top(
        context: context,
        goToPage: const QuranReadPage(
          surahName: SurahNameEnum.alKahf,
        ),
      );
    }

    /// ignore constant alarms if clicked
    else if (payload == "555" || payload == "666") {
    }

    /// go to zikr page if clicked
    else {
      final int pageIndex = int.parse(payload);
      //
      if (sl<AppSettingsRepo>().isCardReadMode) {
        transitionAnimation.fromBottom2Top(
          context: context,
          goToPage: ZikrViewerCardModeScreen(index: pageIndex),
        );
      } else {
        transitionAnimation.fromBottom2Top(
          context: context,
          goToPage: ZikrViewerPageModeScreen(index: pageIndex),
        );
      }
    }
  }

  void dispose() {
    // AwesomeNotifications().actionSink.close();
    // AwesomeNotifications().createdSink.close();
  }
}

class Time {
  final int hour;
  final int minute;
  Time(
    this.hour, [
    this.minute = 0,
  ]);
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
    name: S.current.channelInAppName,
    description: S.current.channelInAppNameDesc,
  );
  static NotifyChannel scheduled = NotifyChannel(
    key: 'scheduled_channel',
    name: S.current.channelScheduledName,
    description: S.current.channelScheduledNameDesc,
  );
}
