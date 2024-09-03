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
  const TallyEditCounterEvent({
    required this.counter,
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
  const TallyToggleCounterActivationEvent({
    required this.counter,
  });

  @override
  List<Object> get props => [counter];
}

class TallyNextCounterEvent extends TallyEvent {}

class TallyPreviousCounterEvent extends TallyEvent {}

class TallyResetAllCountersEvent extends TallyEvent {}

class TallyResetActiveCounterEvent extends TallyEvent {}

class TallyIncreaseActiveCounterEvent extends TallyEvent {}

class TallyDecreaseActiveCounterEvent extends TallyEvent {}
