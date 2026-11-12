// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tally_bloc.dart';

sealed class TallyEvent extends Equatable {
  const TallyEvent();

  @override
  List<Object> get props => [];
}

class TallyStartEvent extends TallyEvent {}

class TallyAddCounterEvent extends TallyEvent {
  final DbTally counter;

  const TallyAddCounterEvent({required this.counter});

  @override
  List<Object> get props => [counter];
}

class TallyEditCounterEvent extends TallyEvent {
  final DbTally counter;
  final Completer? completer;
  const TallyEditCounterEvent({
    required this.counter,
    this.completer,
  });

  @override
  List<Object> get props => [counter];
}

class TallyDeleteCounterEvent extends TallyEvent {
  final DbTally counter;
  const TallyDeleteCounterEvent({
    required this.counter,
  });

  @override
  List<Object> get props => [counter];
}

class TallyToggleCounterActivationEvent extends TallyEvent {
  final DbTally counter;
  final bool activate;
  const TallyToggleCounterActivationEvent({
    required this.counter,
    required this.activate,
  });

  @override
  List<Object> get props => [counter, activate];
}

class TallyNextCounterEvent extends TallyEvent {}

class TallyPreviousCounterEvent extends TallyEvent {}

class TallyRandomCounterEvent extends TallyEvent {}

class TallyResetAllCountersEvent extends TallyEvent {}

class TallyResetActiveCounterEvent extends TallyEvent {}

/// Puts back the counts of [counters] (undo of a reset).
class TallyRestoreCountersEvent extends TallyEvent {
  final List<DbTally> counters;

  const TallyRestoreCountersEvent({required this.counters});

  @override
  List<Object> get props => [counters];
}

class TallyIncreaseActiveCounterEvent extends TallyEvent {
  /// Completed with the counter that is active once the count (and any auto-advance
  /// that follows it) is done. Used by voice playback to know what to play next.
  final Completer<DbTally?>? completer;

  /// Auto-advance only goes to counters that have a recording.
  final bool audioOnly;

  const TallyIncreaseActiveCounterEvent({this.completer, this.audioOnly = false});
}

class TallyDecreaseActiveCounterEvent extends TallyEvent {}

class TallyToggleIterationModeEvent extends TallyEvent {}

class TallySetAdvanceTriggerEvent extends TallyEvent {
  final TallyAdvanceTrigger trigger;

  const TallySetAdvanceTriggerEvent(this.trigger);

  @override
  List<Object> get props => [trigger];
}

/// Sets the auto-advance mode directly (none, circular or shuffle).
class TallySetIterationModeEvent extends TallyEvent {
  final TallyIterationMode mode;

  const TallySetIterationModeEvent(this.mode);

  @override
  List<Object> get props => [mode];
}

class TallyIterateEvent extends TallyEvent {
  final Completer<DbTally?>? completer;
  final bool audioOnly;

  const TallyIterateEvent({this.completer, this.audioOnly = false});
}
