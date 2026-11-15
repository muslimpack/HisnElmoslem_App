// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'alarms_bloc.dart';

sealed class AlarmsState extends Equatable {
  const AlarmsState();

  @override
  List<Object> get props => [];
}

final class AlarmsLoadingState extends AlarmsState {}

class AlarmsLoadedState extends AlarmsState {
  final bool isCaveAlarmEnabled;
  final bool isFastAlarmEnabled;
  final int fastHour;
  final int fastMinute;
  final bool fastSameDay;
  final List<DbAlarm> alarms;

  const AlarmsLoadedState({
    required this.isCaveAlarmEnabled,
    required this.isFastAlarmEnabled,
    required this.alarms,
    this.fastHour = 20,
    this.fastMinute = 0,
    this.fastSameDay = false,
  });

  @override
  List<Object> get props => [
    alarms,
    isCaveAlarmEnabled,
    isFastAlarmEnabled,
    fastHour,
    fastMinute,
    fastSameDay,
  ];

  AlarmsLoadedState copyWith({
    bool? isCaveAlarmEnabled,
    bool? isFastAlarmEnabled,
    int? fastHour,
    int? fastMinute,
    bool? fastSameDay,
    List<DbAlarm>? alarms,
  }) {
    return AlarmsLoadedState(
      isCaveAlarmEnabled: isCaveAlarmEnabled ?? this.isCaveAlarmEnabled,
      isFastAlarmEnabled: isFastAlarmEnabled ?? this.isFastAlarmEnabled,
      alarms: alarms ?? this.alarms,
      fastHour: fastHour ?? this.fastHour,
      fastMinute: fastMinute ?? this.fastMinute,
      fastSameDay: fastSameDay ?? this.fastSameDay,
    );
  }
}
