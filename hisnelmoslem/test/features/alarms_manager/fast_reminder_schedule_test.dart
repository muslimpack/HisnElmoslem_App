import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarms_repo.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_alarm_scheduler.dart';

class _FakeBox extends Fake implements GetStorage {
  final Map<String, dynamic> data = {};

  @override
  T? read<T>(String key) => data[key] as T?;

  @override
  Future<void> write(String key, dynamic value) async => data[key] = value;
}

class _FakeDb extends Fake implements AlarmDatabaseHelper {
  @override
  Future<List<DbAlarm>> getAlarms() async => [];
}

class _FakeScheduler extends Fake implements CustomAlarmScheduler {
  @override
  Future<void> rescheduleAll() async {}
}

class _ScheduledWeekly {
  final int id;
  final String title;
  final int hour;
  final int minute;
  final int weekday;
  _ScheduledWeekly(this.id, this.title, this.hour, this.minute, this.weekday);
}

class _FakeNotifications extends LocalNotificationManager {
  final List<_ScheduledWeekly> weekly = [];

  @override
  Future<void> addCustomWeeklyReminder({
    required int id,
    required String title,
    String? body,
    required String payload,
    required Time time,
    required int weekday,
    bool requestPermission = true,
  }) async {
    weekly.add(_ScheduledWeekly(id, title, time.hour, time.minute, weekday));
  }

  @override
  Future<void> cancelNotificationById({required int id}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBox box;
  late _FakeNotifications notifications;
  late AlarmsBloc bloc;

  setUp(() async {
    SX.init(await S.delegate.load(const Locale('en')));
    box = _FakeBox();
    notifications = _FakeNotifications();
    final db = _FakeDb();
    // AlarmManager.checkAllAlarmsInDb reads these through the service locator.
    await sl.reset();
    sl
      ..registerSingleton<AlarmDatabaseHelper>(db)
      ..registerSingleton<CustomAlarmScheduler>(_FakeScheduler());
    bloc = AlarmsBloc(
      db,
      AlarmsRepo(box),
      AlarmManager(notifications),
      notifications,
    );
    bloc.add(AlarmsStartEvent());
    await bloc.stream.firstWhere((s) => s is AlarmsLoadedState);
  });

  tearDown(() async {
    await bloc.close();
    await sl.reset();
  });

  test('fasting reminders default to the evening before at 20:00', () async {
    await AlarmsRepo(box).changFastAlarmStatus(value: true);
    bloc.add(AlarmsStartEvent());
    await bloc.stream.firstWhere((s) => s is AlarmsLoadedState);

    expect(notifications.weekly.map((w) => w.weekday), [DateTime.sunday, DateTime.wednesday]);
    expect(notifications.weekly.every((w) => w.hour == 20 && w.minute == 0), isTrue);
  });

  test('a chosen time on the fasting day moves the weekday and the title', () async {
    await AlarmsRepo(box).changFastAlarmStatus(value: true);

    bloc.add(const AlarmsFastScheduleChangedEvent(hour: 6, minute: 30, sameDay: true));
    final state = await bloc.stream.firstWhere(
      (s) => s is AlarmsLoadedState && s.fastSameDay,
    );

    expect((state as AlarmsLoadedState).fastHour, 6);
    expect(notifications.weekly.map((w) => w.id), [555, 666]);
    expect(notifications.weekly.map((w) => w.weekday), [DateTime.monday, DateTime.thursday]);
    expect(notifications.weekly.every((w) => w.hour == 6 && w.minute == 30), isTrue);
    expect(notifications.weekly.first.title, SX.current.fastingMondayTodayReminder);
    expect(box.data['fast_same_day'], isTrue);
  });

  test('changing the schedule while the reminder is off schedules nothing', () async {
    bloc.add(const AlarmsFastScheduleChangedEvent(hour: 7, minute: 0, sameDay: false));
    await bloc.stream.firstWhere((s) => s is AlarmsLoadedState && s.fastHour == 7);

    expect(notifications.weekly, isEmpty);
    expect(box.data['fast_hour'], 7);
  });
}
