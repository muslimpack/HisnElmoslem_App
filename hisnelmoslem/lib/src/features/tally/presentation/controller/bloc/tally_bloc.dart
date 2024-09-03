// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';

part 'tally_event.dart';
part 'tally_state.dart';

class TallyBloc extends Bloc<TallyEvent, TallyState> {
  final TallyDatabaseHelper tallyDatabaseHelper;
  final _volumeBtnChannel = const MethodChannel("volume_button_channel");
  TallyBloc(
    this.tallyDatabaseHelper,
  ) : super(TallyLoadingState()) {
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
    on<TallyToggleCounterActivationEvent>(_toggleCounterActivation);
    on<TallyNextCounterEvent>(_nextCounter);
    on<TallyPreviousCounterEvent>(_previousCounter);
    on<TallyRandomCounterEvent>(_randomCounter);
    on<TallyResetAllCountersEvent>(_resetAllCounters);
    on<TallyResetActiveCounterEvent>(_resetActiveCounter);
    on<TallyIncreaseActiveCounterEvent>(_increaseActiveCounter);
    on<TallyDecreaseActiveCounterEvent>(_decreaseActiveCounter);
    on<TallyToggleIterationModeEvent>(_toggleIterationMode);
    on<TallyIterateEvent>(_iterate);
  }

  FutureOr<void> _start(
    TallyStartEvent event,
    Emitter<TallyState> emit,
  ) async {
    final allCounters = await tallyDatabaseHelper.getAllTally();

    emit(
      TallyLoadedState(
        allCounters: allCounters,
        activeCounter: allCounters.where((x) => x.isActivated).firstOrNull,
        iterationMode: TallyIterationMode.none,
      ),
    );
  }

  FutureOr<void> _addCounter(
    TallyAddCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    await tallyDatabaseHelper.addNewTally(dbTally: event.counter);

    final updatedCounters = List<DbTally>.from(state.allCounters)
      ..add(event.counter);

    emit(state.copyWith(allCounters: updatedCounters));
  }

  FutureOr<void> _editCounter(
    TallyEditCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    await tallyDatabaseHelper.updateTally(
      dbTally: event.counter,
      updateTime: false,
    );

    final updatedCounters = List<DbTally>.from(state.allCounters)
        .map((x) => x.copyWith())
        .map((counter) {
      if (counter.id == event.counter.id) {
        return event.counter;
      }
      return counter;
    }).toList();

    late final DbTally? activeCounter;

    if (state.activeCounter?.id == event.counter.id ||
        event.counter.isActivated) {
      activeCounter = event.counter;
    } else {
      activeCounter = state.activeCounter;
    }

    emit(
      state.copyWith(
        allCounters: updatedCounters,
        activeCounter: activeCounter,
      ),
    );
  }

  FutureOr<void> _deleteCounter(
    TallyDeleteCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    await tallyDatabaseHelper.deleteTally(dbTally: event.counter);

    final updatedCounters = state.allCounters
        .where((counter) => counter.id != event.counter.id)
        .toList();

    emit(
      state.copyWith(
        allCounters: updatedCounters,
        activeCounter: state.activeCounter?.id == event.counter.id
            ? null
            : state.activeCounter,
      ),
    );
  }

  FutureOr<void> _toggleCounterActivation(
    TallyToggleCounterActivationEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final updatedCounters = List<DbTally>.from(state.allCounters);
    for (final counter in updatedCounters) {
      if (counter.id == event.counter.id) {
        counter.isActivated = !counter.isActivated;
        await tallyDatabaseHelper.updateTally(
          dbTally: counter,
          updateTime: false,
        );
      } else if (counter.isActivated) {
        counter.isActivated = false;
        await tallyDatabaseHelper.updateTally(
          dbTally: counter,
          updateTime: false,
        );
      }
    }

    final DbTally? activeCounter =
        updatedCounters.where((x) => x.isActivated).firstOrNull;

    emit(
      state.copyWith(
        allCounters: updatedCounters,
        activeCounter: activeCounter,
      ),
    );
  }

  FutureOr<void> _nextCounter(
    TallyNextCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeCounterIndex =
        state.allCounters.indexWhere((x) => x.isActivated);
    if (activeCounterIndex == -1) return;

    final nextCounterIndex =
        (activeCounterIndex + 1) % state.allCounters.length;
    final nextCounter = state.allCounters[nextCounterIndex];
    add(TallyToggleCounterActivationEvent(counter: nextCounter));
  }

  FutureOr<void> _previousCounter(
    TallyPreviousCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeCounterIndex =
        state.allCounters.indexWhere((x) => x.isActivated);
    if (activeCounterIndex == -1) return;

    final previousCounterIndex =
        (activeCounterIndex - 1) % state.allCounters.length;
    final previousCounter = state.allCounters[previousCounterIndex];
    add(TallyToggleCounterActivationEvent(counter: previousCounter));
  }

  FutureOr<void> _randomCounter(
    TallyRandomCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeCounterIndex =
        state.allCounters.indexWhere((x) => x.isActivated);
    if (activeCounterIndex == -1) return;

    int randomIndex;
    do {
      randomIndex = Random().nextInt(state.allCounters.length);
    } while (randomIndex == activeCounterIndex && state.allCounters.length > 2);

    final randomCounter = state.allCounters[randomIndex];
    add(TallyToggleCounterActivationEvent(counter: randomCounter));
  }

  FutureOr<void> _resetAllCounters(
    TallyResetAllCountersEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final updatedCounters = List<DbTally>.from(state.allCounters)
        .map((x) => x.copyWith(count: 0))
        .toList();

    await tallyDatabaseHelper.updateTallies(
      dbTallies: updatedCounters,
      updateTime: true,
    );

    emit(
      state.copyWith(
        allCounters: updatedCounters,
      ),
    );
  }

  FutureOr<void> _resetActiveCounter(
    TallyResetActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeCounter = state.activeCounter;
    if (activeCounter == null) return;

    add(
      TallyEditCounterEvent(
        counter: activeCounter.copyWith(count: 0),
      ),
    );
  }

  FutureOr<void> _increaseActiveCounter(
    TallyIncreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;
    final activeCounter = state.activeCounter;
    if (activeCounter == null) return;

    add(
      TallyEditCounterEvent(
        counter: activeCounter.copyWith(count: activeCounter.count + 1),
      ),
    );

    add(TallyIterateEvent());
  }

  FutureOr<void> _decreaseActiveCounter(
    TallyDecreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;
    final activeCounter = state.activeCounter;
    if (activeCounter == null) return;

    add(
      TallyEditCounterEvent(
        counter: activeCounter.copyWith(
          count: (activeCounter.count - 1).clamp(0, activeCounter.count),
        ),
      ),
    );
  }

  FutureOr<void> _toggleIterationMode(
    TallyToggleIterationModeEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final nextModeIndex =
        (state.iterationMode.index + 1) % TallyIterationMode.values.length;
    emit(
      state.copyWith(
        iterationMode: TallyIterationMode.values[nextModeIndex],
      ),
    );
  }

  FutureOr<void> _iterate(
    TallyIterateEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    switch (state.iterationMode) {
      case TallyIterationMode.none:
        break;
      case TallyIterationMode.circular:
        add(TallyNextCounterEvent());
      case TallyIterationMode.shuffle:
        add(TallyRandomCounterEvent());
    }
  }

  @override
  Future<void> close() async {
    _volumeBtnChannel.setMethodCallHandler(null);
    return super.close();
  }
}
