import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';

part 'tally_event.dart';
part 'tally_state.dart';

class TallyBloc extends Bloc<TallyEvent, TallyState> {
  TallyBloc() : super(TallyLoadingState()) {
    on<TallyStartEvent>(_start);
    on<TallyAddCounterEvent>(_addCounter);
    on<TallyEditCounterEvent>(_editCounter);
    on<TallyDeleteCounterEvent>(_deleteCounter);
    on<TallyActivateCounterEvent>(_activateCounter);
    on<TallyNextCounterEvent>(_nextCounter);
    on<TallyPreviousCounterEvent>(_previousCounter);
    on<TallyResetAllCountersEvent>(_resetAllCounters);
    on<TallyResetActiveCounterEvent>(_resetActiveCounter);
    on<TallyIncreaseActiveCounterEvent>(_increaseActiveCounter);
    on<TallyDecreaseActiveCounterEvent>(_decreaseActiveCounter);
  }

  FutureOr<void> _start(
    TallyStartEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _addCounter(
    TallyAddCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _editCounter(
    TallyEditCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _deleteCounter(
    TallyDeleteCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _activateCounter(
    TallyActivateCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _nextCounter(
    TallyNextCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _previousCounter(
    TallyPreviousCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _resetAllCounters(
    TallyResetAllCountersEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _resetActiveCounter(
    TallyResetActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _increaseActiveCounter(
    TallyIncreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) {}

  FutureOr<void> _decreaseActiveCounter(
    TallyDecreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) {}
}
