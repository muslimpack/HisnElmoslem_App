import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  AlarmsBloc() : super(AlarmsLoadingState()) {
    on<AlarmsStartEvent>(_start);
    on<AlarmsAddEvent>(_add);
    on<AlarmsEditEvent>(_edit);
    on<AlarmsRemoveEvent>(_remove);
  }

  FutureOr<void> _start(
    AlarmsStartEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final alarms = await alarmDatabaseHelper.getAlarms();
    emit(AlarmsLoadedState(alarms: alarms));
  }

  FutureOr<void> _add(
    AlarmsAddEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmDatabaseHelper.addNewAlarm(dbAlarm: event.alarm);
    await alarmManager.alarmState(dbAlarm: event.alarm);

    final alarms = List<DbAlarm>.from(state.alarms)..add(event.alarm);

    emit(AlarmsLoadedState(alarms: alarms));
  }

  FutureOr<void> _edit(
    AlarmsEditEvent event,
    Emitter<AlarmsState> emit,
  ) async {
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

    emit(AlarmsLoadedState(alarms: alarms));
  }

  FutureOr<void> _remove(
    AlarmsRemoveEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    await alarmDatabaseHelper.deleteAlarm(dbAlarm: event.alarm);
    final alarms = List<DbAlarm>.from(state.alarms);
    alarms.removeWhere((x) => x.id == event.alarm.id);

    await awesomeNotificationManager.cancelNotificationById(
      id: event.alarm.titleId,
    );

    getSnackbar(
      message: "${"Reminder Removed".tr} | ${event.alarm.title}",
    );

    emit(AlarmsLoadedState(alarms: alarms));
  }
}
