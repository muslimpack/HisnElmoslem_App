// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_day.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarms_repo.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  final AlarmDatabaseHelper alarmDatabaseHelper;
  final AlarmsRepo alarmsRepo;
  AlarmsBloc(
    this.alarmDatabaseHelper,
    this.alarmsRepo,
  ) : super(AlarmsLoadingState()) {
    on<AlarmsStartEvent>(_start);
    on<AlarmsAddEvent>(_add);
    on<AlarmsEditEvent>(_edit);
    on<AlarmsRemoveEvent>(_remove);
    on<AlarmsToggleFastAlarmEvent>(_toggleFastAlarm);
    on<AlarmsToggleCaveAlarmEvent>(_toggleCaveAlarm);
  }

  FutureOr<void> _start(
    AlarmsStartEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final alarms = await alarmDatabaseHelper.getAlarms();
    emit(
      AlarmsLoadedState(
        alarms: alarms,
        isCaveAlarmEnabled: alarmsRepo.isCaveAlarmEnabled,
        isFastAlarmEnabled: alarmsRepo.isFastAlarmEnabled,
      ),
    );
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

    emit(state.copyWith(alarms: alarms));
  }

  FutureOr<void> _edit(
    AlarmsEditEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    hisnPrint("object ${event.alarm.id}");

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

    showToast(
      msg: "${"Reminder Removed".tr} | ${event.alarm.title}",
    );

    emit(state.copyWith(alarms: alarms));
  }

  FutureOr<void> _toggleFastAlarm(
    AlarmsToggleFastAlarmEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;
    alarmsRepo.changFastAlarmStatus(value: event.enable);

    if (event.enable) {
      showToast(
        msg:
            "${"activate".tr} | ${"fasting mondays and thursdays reminder".tr}",
      );
    } else {
      showToast(
        msg:
            "${"deactivate".tr} | ${"fasting mondays and thursdays reminder".tr}",
      );
    }

    _activateFastAlarm(value: event.enable);

    emit(state.copyWith(isFastAlarmEnabled: event.enable));
  }

  FutureOr<void> _toggleCaveAlarm(
    AlarmsToggleCaveAlarmEvent event,
    Emitter<AlarmsState> emit,
  ) async {
    final state = this.state;
    if (state is! AlarmsLoadedState) return;

    alarmsRepo.changCaveAlarmStatus(value: event.enable);

    if (event.enable) {
      showToast(
        msg: "${"activate".tr} | ${"sura Al-Kahf reminder".tr}",
      );
    } else {
      showToast(
        msg: "${"deactivate".tr} | ${"sura Al-Kahf reminder".tr}",
      );
    }

    _activateCaveAlarm(value: event.enable);
    emit(state.copyWith(isCaveAlarmEnabled: event.enable));
  }

  Future _activateCaveAlarm({required bool value}) async {
    if (value) {
      await awesomeNotificationManager.addCustomWeeklyReminder(
        id: 555,
        title: "صيام غدا الإثنين",
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: Time(20),
        weekday: AwesomeDay.sunday.value,
        payload: "555",
        needToOpen: false,
      );
      await awesomeNotificationManager.addCustomWeeklyReminder(
        id: 666,
        title: "صيام غدا الخميس",
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: Time(20),
        weekday: AwesomeDay.wednesday.value,
        payload: "666",
        needToOpen: false,
      );
    } else {
      await awesomeNotificationManager.cancelNotificationById(id: 555);
      await awesomeNotificationManager.cancelNotificationById(id: 666);
    }
  }

  Future _activateFastAlarm({required bool value}) async {
    if (value) {
      await awesomeNotificationManager.addCustomWeeklyReminder(
        id: 777,
        title: "sura Al-Kahf".tr,
        body:
            "روى الحاكم في المستدرك مرفوعا إن من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين. وصححه الألباني",
        time: Time(
          9,
        ),
        weekday: AwesomeDay.friday.value,
        payload: "الكهف",
        needToOpen: false,
      );
    } else {
      await awesomeNotificationManager.cancelNotificationById(id: 777);
    }
  }
}
