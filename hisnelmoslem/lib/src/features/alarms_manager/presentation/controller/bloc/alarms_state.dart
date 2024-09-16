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
  final List<DbAlarm> alarms;

  const AlarmsLoadedState({
    required this.isCaveAlarmEnabled,
    required this.isFastAlarmEnabled,
    required this.alarms,
  });

  @override
  List<Object> get props => [alarms, isCaveAlarmEnabled, isFastAlarmEnabled];

  AlarmsLoadedState copyWith({
    bool? isCaveAlarmEnabled,
    bool? isFastAlarmEnabled,
    List<DbAlarm>? alarms,
  }) {
    return AlarmsLoadedState(
      isCaveAlarmEnabled: isCaveAlarmEnabled ?? this.isCaveAlarmEnabled,
      isFastAlarmEnabled: isFastAlarmEnabled ?? this.isFastAlarmEnabled,
      alarms: alarms ?? this.alarms,
    );
  }
}
