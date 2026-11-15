// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarms_repo.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  final AlarmDatabaseHelper alarmDatabaseHelper;
  final AlarmsRepo alarmsRepo;
  final AlarmManager alarmManager;
  final LocalNotificationManager localNotificationManager;

  /// How long after start the alarms are planned with the system, so the first screens
  /// are drawn and loaded before that work starts.
  final Duration replanDelay;

  /// Windows keeps its scheduled toasts across restarts and the plan only needs topping
  /// up, so a launch within this time of the last plan skips the work.
  static const Duration _windowsReplanEvery = Duration(hours: 20);

  Future<void> _replanTail = Future<void>.value();

  /// Completes when the background planning queued so far is done.
  @visibleForTesting
  Future<void> get replanIdle => _replanTail;

  AlarmsBloc(
    this.alarmDatabaseHelper,
    this.alarmsRepo,
    this.alarmManager,
    this.localNotificationManager, {
    this.replanDelay = const Duration(seconds: 2),
  }) : super(AlarmsLoadingState()) {
    on<AlarmsStartEvent>(_start);
    on<AlarmsAddEvent>(_add);
    on<AlarmsEditEvent>(_edit);
    on<AlarmsRemoveEvent>(_remove);
    on<AlarmsToggleFastAlarmEvent>(_toggleFastAlarm);
    on<AlarmsToggleCaveAlarmEvent>(_toggleCaveAlarm);
    on<AlarmsFastScheduleChangedEvent>(_changeFastSchedule);
  }

  Future<void> _start(AlarmsStartEvent event, Emitter<AlarmsState> emit) async {
    final alarms = await alarmDatabaseHelper.getAlarms();

    // Show the alarms now. Planning them with the system takes a platform call per
    // alarm and must not keep the buttons from appearing.
    emit(
      AlarmsLoadedState(
        alarms: alarms,
        isCaveAlarmEnabled: alarmsRepo.isCaveAlarmEnabled,
        isFastAlarmEnabled: alarmsRepo.isFastAlarmEnabled,
        fastHour: alarmsRepo.fastAlarmHour,
        fastMinute: alarmsRepo.fastAlarmMinute,
        fastSameDay: alarmsRepo.fastAlarmSameDay,
      ),
    );

    _queueReplan(force: event.forceReplan);
  }

  void _queueReplan({required bool force}) {
    // One run at a time, in the order they were asked for.
    _replanTail = _replanTail.then((_) => _replan(force: force)).catchError((Object e) {
      hisnPrint(e);
    });
  }

  /// Plans every stored alarm again with the system. Needed at launch because alarms
  /// are lost when the app was force-stopped or its data restored.
  Future<void> _replan({required bool force}) async {
    if (!force && Platform.isWindows) {
      final last = alarmsRepo.lastPlannedAtMs;
      if (last != null &&
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(last)) <
              _windowsReplanEvery) {
        return;
      }
    }

    if (!force) await Future<void>.delayed(replanDelay);

    await alarmManager.checkAllAlarmsInDb();

    if (alarmsRepo.isCaveAlarmEnabled) {
      await _activateCaveReminders(value: true, requestPermission: false);
    }
    if (alarmsRepo.isFastAlarmEnabled) {
      await _activateFastReminders(value: true, requestPermission: false);
    }

    await alarmsRepo.markPlanned();
  }

  Future<void> _changeFastSchedule(
    AlarmsFastScheduleChangedEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmsRepo.changeFastSchedule(
      hour: event.hour,
      minute: event.minute,
      sameDay: event.sameDay,
    );
    if (alarmsRepo.isFastAlarmEnabled) {
      await _activateFastReminders(value: true, requestPermission: false);
    }

    emit(
      state.copyWith(
        fastHour: event.hour,
        fastMinute: event.minute,
        fastSameDay: event.sameDay,
      ),
    );
  }

  Future<void> _add(AlarmsAddEvent event, Emitter<AlarmsState> emit) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    final id = await alarmDatabaseHelper.addNewAlarm(dbAlarm: event.alarm);
    final dbAlarm = event.alarm.copyWith(id: id);

    await alarmManager.alarmState(dbAlarm: dbAlarm);

    final alarms = List<DbAlarm>.from(state.alarms)..add(dbAlarm);

    emit(state.copyWith(alarms: alarms));
  }

  Future<void> _edit(AlarmsEditEvent event, Emitter<AlarmsState> emit) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmDatabaseHelper.updateAlarmInfo(dbAlarm: event.alarm);
    await alarmManager.alarmState(dbAlarm: event.alarm);

    final alarms = List<DbAlarm>.from(state.alarms).map((x) {
      if (x.id == event.alarm.id) {
        return event.alarm;
      }
      return x;
    }).toList();

    emit(state.copyWith(alarms: alarms));
  }

  Future<void> _remove(
    AlarmsRemoveEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmDatabaseHelper.deleteAlarm(dbAlarm: event.alarm);
    final alarms = List<DbAlarm>.from(state.alarms);
    alarms.removeWhere((x) => x.id == event.alarm.id);

    await localNotificationManager.cancelNotificationById(
      id: event.alarm.titleId,
    );

    showToast(msg: "${SX.current.reminderRemoved}: ${event.alarm.title}");

    emit(state.copyWith(alarms: alarms));
  }

  Future<void> _toggleFastAlarm(
    AlarmsToggleFastAlarmEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;
    alarmsRepo.changFastAlarmStatus(value: event.enable);

    if (event.enable) {
      showToast(
        msg: "${SX.current.activate}: ${SX.current.fastingMondaysThursdaysReminder}",
      );
    } else {
      showToast(
        msg: "${SX.current.deactivate}: ${SX.current.fastingMondaysThursdaysReminder}",
      );
    }

    _activateFastReminders(value: event.enable);

    emit(state.copyWith(isFastAlarmEnabled: event.enable));
  }

  Future<void> _toggleCaveAlarm(
    AlarmsToggleCaveAlarmEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmsRepo.changCaveAlarmStatus(value: event.enable);

    if (event.enable) {
      showToast(
        msg: "${SX.current.activate}: ${SX.current.suraAlKahfReminder}",
      );
    } else {
      showToast(
        msg: "${SX.current.deactivate}: ${SX.current.suraAlKahfReminder}",
      );
    }

    await _activateCaveReminders(value: event.enable);
    emit(state.copyWith(isCaveAlarmEnabled: event.enable));
  }

  Future _activateFastReminders({
    required bool value,
    bool requestPermission = true,
  }) async {
    if (value) {
      final sameDay = alarmsRepo.fastAlarmSameDay;
      final time = Time(alarmsRepo.fastAlarmHour, alarmsRepo.fastAlarmMinute);
      await localNotificationManager.addCustomWeeklyReminder(
        id: 555,
        title: sameDay ? SX.current.fastingMondayTodayReminder : SX.current.fastingMondayReminder,
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: time,
        weekday: sameDay ? DateTime.monday : DateTime.sunday,
        payload: "555",
        requestPermission: requestPermission,
      );
      await localNotificationManager.addCustomWeeklyReminder(
        id: 666,
        title: sameDay
            ? SX.current.fastingThursdayTodayReminder
            : SX.current.fastingThursdayReminder,
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: time,
        weekday: sameDay ? DateTime.thursday : DateTime.wednesday,
        payload: "666",
        requestPermission: requestPermission,
      );
    } else {
      await localNotificationManager.cancelNotificationById(id: 555);
      await localNotificationManager.cancelNotificationById(id: 666);
    }
  }

  Future _activateCaveReminders({
    required bool value,
    bool requestPermission = true,
  }) async {
    if (value) {
      await localNotificationManager.addCustomWeeklyReminder(
        id: 777,
        title: SX.current.suraAlKahf,
        body:
            "روى الحاكم في المستدرك مرفوعا إن من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين. وصححه الألباني",
        time: Time(9),
        weekday: DateTime.friday,
        payload: "الكهف",
        requestPermission: requestPermission,
      );
    } else {
      await localNotificationManager.cancelNotificationById(id: 777);
    }
  }
}
