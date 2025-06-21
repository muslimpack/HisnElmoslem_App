// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tally_bloc.dart';

sealed class TallyState extends Equatable {
  const TallyState();

  @override
  List<Object?> get props => [];
}

final class TallyLoadingState extends TallyState {}

final class TallyLoadedState extends TallyState {
  final List<DbTally> allCounters;
  final TallyIterationMode iterationMode;
  final bool loadingIteration;

  const TallyLoadedState({
    required this.allCounters,
    required this.iterationMode,
    required this.loadingIteration,
  });

  DbTally? get activeCounter =>
      allCounters.where((x) => x.isActivated).firstOrNull;

  double get resetEvery => switch (iterationMode) {
    TallyIterationMode.none => activeCounter?.countReset.toDouble() ?? 1,
    _ => 33,
  };

  int get maxCounterNumberLength =>
      allCounters.fold(0, (prev, e) => max(prev, e.count.toString().length));

  TallyLoadedState copyWith({
    List<DbTally>? allCounters,
    TallyIterationMode? iterationMode,
    bool? loadingIteration,
  }) {
    return TallyLoadedState(
      allCounters: allCounters ?? this.allCounters,
      iterationMode: iterationMode ?? this.iterationMode,
      loadingIteration: loadingIteration ?? this.loadingIteration,
    );
  }

  @override
  List<Object?> get props => [
    allCounters,
    activeCounter,
    iterationMode,
    loadingIteration,
  ];
}
