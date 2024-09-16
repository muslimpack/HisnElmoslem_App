// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'alarms_bloc.dart';

sealed class AlarmsEvent extends Equatable {
  const AlarmsEvent();

  @override
  List<Object> get props => [];
}

class AlarmsStartEvent extends AlarmsEvent {}

class AlarmsAddEvent extends AlarmsEvent {
  final DbAlarm alarm;
  const AlarmsAddEvent(
    this.alarm,
  );

  @override
  List<Object> get props => [alarm];
}

class AlarmsEditEvent extends AlarmsEvent {
  final DbAlarm alarm;
  const AlarmsEditEvent(
    this.alarm,
  );

  @override
  List<Object> get props => [alarm];
}

class AlarmsRemoveEvent extends AlarmsEvent {
  final DbAlarm alarm;
  const AlarmsRemoveEvent(
    this.alarm,
  );

  @override
  List<Object> get props => [alarm];
}

class AlarmsToggleCaveAlarmEvent extends AlarmsEvent {
  final bool enable;

  const AlarmsToggleCaveAlarmEvent(this.enable);

  @override
  List<Object> get props => [enable];
}

class AlarmsToggleFastAlarmEvent extends AlarmsEvent {
  final bool enable;

  const AlarmsToggleFastAlarmEvent(this.enable);

  @override
  List<Object> get props => [enable];
}
