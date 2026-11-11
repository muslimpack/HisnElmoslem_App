import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';

/// Schedules the local notification of a custom title's alarm.
///
/// Notification ids start at [notificationIdBase] so they can never collide with
/// original title alarms (ids 1..~130) or the reserved constant alarms (555/666).
/// The payload is `custom:<titleId>` and is routed by `onNotificationClick`.
class CustomAlarmScheduler {
  static const int notificationIdBase = 1000000;
  static const String payloadPrefix = "custom:";

  final LocalNotificationManager notifications;
  final CustomAzkarRepo repo;

  const CustomAlarmScheduler(this.notifications, this.repo);

  static int notificationId(int titleId) => notificationIdBase + titleId;

  static String payloadFor(int titleId) => "$payloadPrefix$titleId";

  /// Returns the custom title id encoded in a notification payload, if any.
  static int? titleIdFromPayload(String payload) {
    if (!payload.startsWith(payloadPrefix)) return null;
    return int.tryParse(payload.substring(payloadPrefix.length));
  }

  /// Schedules the alarm when active, cancels it otherwise.
  Future<void> apply(
    CustomAlarm alarm,
    String titleName, {
    bool requestPermission = true,
  }) async {
    if (!alarm.isActive) {
      await cancel(alarm.titleId);
      return;
    }

    final id = notificationId(alarm.titleId);
    final time = Time(alarm.hour, alarm.minute);
    final payload = payloadFor(alarm.titleId);

    if (alarm.repeatType == AlarmRepeatType.daily) {
      await notifications.addCustomDailyReminder(
        id: id,
        title: titleName,
        body: alarm.body,
        time: time,
        payload: payload,
        requestPermission: requestPermission,
      );
    } else {
      await notifications.addCustomWeeklyReminder(
        id: id,
        title: titleName,
        body: alarm.body,
        time: time,
        weekday: alarm.repeatType.getWeekDay(),
        payload: payload,
        requestPermission: requestPermission,
      );
    }
  }

  Future<void> cancel(int titleId) {
    return notifications.cancelNotificationById(id: notificationId(titleId));
  }

  /// Re-registers every stored alarm (app start, after a restore, after renames)
  /// and cancels pending custom notifications that no longer have an alarm.
  Future<void> rescheduleAll() async {
    final alarms = await repo.getAlarms();
    final knownIds = alarms.map((a) => notificationId(a.titleId)).toSet();

    try {
      final pending = await notifications.flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= notificationIdBase && !knownIds.contains(request.id)) {
          await notifications.cancelNotificationById(id: request.id);
        }
      }
    } catch (e) {
      // Not every platform can list pending notifications; stale ones are harmless.
      hisnPrint(e);
    }

    for (final alarm in alarms) {
      final title = await repo.getTitle(alarm.titleId);
      if (title == null) {
        await cancel(alarm.titleId);
        continue;
      }
      await apply(alarm, title.name, requestPermission: false);
    }
  }
}
