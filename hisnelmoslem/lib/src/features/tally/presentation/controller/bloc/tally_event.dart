part of 'tally_bloc.dart';

sealed class TallyEvent extends Equatable {
  const TallyEvent();

  @override
  List<Object> get props => [];
}

class TallyStartEvent extends TallyEvent {}

class TallyAddCounterEvent extends TallyEvent {}

class TallyEditCounterEvent extends TallyEvent {}

class TallyDeleteCounterEvent extends TallyEvent {}

class TallyActivateCounterEvent extends TallyEvent {}

class TallyNextCounterEvent extends TallyEvent {}

class TallyPreviousCounterEvent extends TallyEvent {}

class TallyResetAllCountersEvent extends TallyEvent {}

class TallyResetActiveCounterEvent extends TallyEvent {}

class TallyIncreaseActiveCounterEvent extends TallyEvent {}

class TallyDecreaseActiveCounterEvent extends TallyEvent {}
