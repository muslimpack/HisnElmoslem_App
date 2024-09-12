part of 'alarms_bloc.dart';

sealed class AlarmsState extends Equatable {
  const AlarmsState();

  @override
  List<Object> get props => [];
}

final class AlarmsLoadingState extends AlarmsState {}

final class AlarmsLoadedState extends AlarmsState {
  final List<DbAlarm> alarms;

  const AlarmsLoadedState({required this.alarms});

  @override
  List<Object> get props => [alarms];
}
