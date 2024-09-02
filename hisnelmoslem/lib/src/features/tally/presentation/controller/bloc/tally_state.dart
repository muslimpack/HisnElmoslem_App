part of 'tally_bloc.dart';

sealed class TallyState extends Equatable {
  const TallyState();

  @override
  List<Object> get props => [];
}

final class TallyLoadingState extends TallyState {}

final class TallyLoadedState extends TallyState {
  final List<DbTally> allCounters;
  final DbTally? activeCounter;
  final TallyIterationMode iterationMode;

  const TallyLoadedState({
    required this.allCounters,
    required this.activeCounter,
    required this.iterationMode,
  });
}
