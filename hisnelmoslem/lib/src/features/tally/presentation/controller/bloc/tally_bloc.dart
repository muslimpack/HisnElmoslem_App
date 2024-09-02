import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';

part 'tally_event.dart';
part 'tally_state.dart';

class TallyBloc extends Bloc<TallyEvent, TallyState> {
  final _volumeBtnChannel = const MethodChannel("volume_button_channel");
  TallyBloc() : super(TallyLoadingState()) {
    _initHandlers();

    _volumeBtnChannel.setMethodCallHandler((call) async {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          add(TallyIncreaseActiveCounterEvent());
        } else if (call.arguments == "VOLUME_UP_UP") {
          add(TallyIncreaseActiveCounterEvent());
        }
      }
    });
  }

  void _initHandlers() {
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
  ) async {
    final allCounters = await tallyDatabaseHelper.getAllTally();

    emit(
      TallyLoadedState(
        allCounters: allCounters,
        activeCounter: allCounters.firstOrNull,
        iterationMode: TallyIterationMode.none,
      ),
    );
  }

  FutureOr<void> _addCounter(
    TallyAddCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _editCounter(
    TallyEditCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _deleteCounter(
    TallyDeleteCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _activateCounter(
    TallyActivateCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _nextCounter(
    TallyNextCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _previousCounter(
    TallyPreviousCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _resetAllCounters(
    TallyResetAllCountersEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _resetActiveCounter(
    TallyResetActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _increaseActiveCounter(
    TallyIncreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  FutureOr<void> _decreaseActiveCounter(
    TallyDecreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {}

  @override
  Future<void> close() async {
    _volumeBtnChannel.setMethodCallHandler(null);
    return super.close();
  }
}
