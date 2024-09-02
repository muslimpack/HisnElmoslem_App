// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  TallyLoadedState copyWith({
    List<DbTally>? allCounters,
    Object? activeCounter = _notProvided,
    TallyIterationMode? iterationMode,
  }) {
    return TallyLoadedState(
      allCounters: allCounters ?? this.allCounters,
      activeCounter: activeCounter == _notProvided
          ? this.activeCounter
          : activeCounter as DbTally?,
      iterationMode: iterationMode ?? this.iterationMode,
    );
  }

  static const _notProvided = Object();
}
