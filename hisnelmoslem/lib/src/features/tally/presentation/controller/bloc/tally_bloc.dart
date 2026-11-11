// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_advance_trigger.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_repo.dart';

part 'tally_event.dart';
part 'tally_state.dart';

class TallyBloc extends Bloc<TallyEvent, TallyState> {
  final TallyDatabaseHelper tallyDatabaseHelper;
  final EffectsManager effectsManager;
  final VolumeButtonManager volumeButtonManager;
  final TallyRepo tallyRepo;
  StreamSubscription? _volumeSubscription;

  /// How long a count stays visible before auto-advance moves to the next counter.
  static const Duration advanceDelay = Duration(milliseconds: 350);

  TallyBloc(
    this.tallyDatabaseHelper,
    this.effectsManager,
    this.volumeButtonManager,
    this.tallyRepo,
  ) : super(TallyLoadingState()) {
    _initHandlers();

    volumeButtonManager.toggleActivation(
      activate: sl<AppSettingsRepo>().praiseWithVolumeKeys,
    );

    _volumeSubscription = volumeButtonManager.stream.listen((event) {
      if (event == VolumeButtonEvent.volumeUpDown || event == VolumeButtonEvent.volumeDownDown) {
        add(const TallyIncreaseActiveCounterEvent());
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
    on<TallyRestoreCountersEvent>(_restoreCounters);
    on<TallyResetActiveCounterEvent>(_resetActiveCounter);
    // Counting one at a time keeps fast taps from reading the same old value.
    on<TallyIncreaseActiveCounterEvent>(
      _increaseActiveCounter,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
    on<TallyDecreaseActiveCounterEvent>(_decreaseActiveCounter);
    on<TallyToggleIterationModeEvent>(_toggleIterationMode);
    on<TallySetIterationModeEvent>(_setIterationMode);
    on<TallySetAdvanceTriggerEvent>(_setAdvanceTrigger);
    on<TallyIterateEvent>(_iterate);
  }

  Future<void> _start(TallyStartEvent event, Emitter<TallyState> emit) async {
    final allCounters = await tallyDatabaseHelper.getAllTally();

    emit(
      TallyLoadedState(
        allCounters: allCounters,
        iterationMode: tallyRepo.getIterationMode,
        advanceTrigger: tallyRepo.getAdvanceTrigger,
        loadingIteration: false,
      ),
    );
  }

  Future<void> _addCounter(
    TallyAddCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final counterToAdd = event.counter.copyWith(
      lastUpdate: DateTime.now(),
      created: DateTime.now(),
      // activate added tally when tally list is empty
      isActivated: state.allCounters.isEmpty,
    );

    final counterId = await tallyDatabaseHelper.addNewTally(
      dbTally: counterToAdd,
    );

    final updatedCounters = List<DbTally>.from(state.allCounters)
      ..add(counterToAdd.copyWith(id: counterId));

    emit(state.copyWith(allCounters: updatedCounters));
  }

  Future<void> _editCounter(
    TallyEditCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final counterToEdit = event.counter.copyWith(lastUpdate: DateTime.now());

    await tallyDatabaseHelper.updateTally(dbTally: counterToEdit);

    final updatedCounters = List<DbTally>.from(state.allCounters).map((
      counter,
    ) {
      if (counter.id == counterToEdit.id) {
        return counterToEdit;
      }
      return counter;
    }).toList();

    emit(state.copyWith(allCounters: updatedCounters));

    await Future.delayed(const Duration(milliseconds: 350));
    event.completer?.complete();
  }

  Future<void> _deleteCounter(
    TallyDeleteCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    await tallyDatabaseHelper.deleteTally(dbTally: event.counter);

    final updatedCounters = state.allCounters
        .where((counter) => counter.id != event.counter.id)
        .toList();

    emit(state.copyWith(allCounters: updatedCounters));
  }

  /// Makes [target] the only active counter. Only the rows that change are written.
  Future<List<DbTally>> _activate(
    TallyLoadedState state,
    DbTally target,
    Emitter<TallyState> emit,
  ) async {
    final updated = <DbTally>[];
    for (final counter in state.allCounters) {
      final shouldBeActive = counter.id == target.id;
      if (counter.isActivated == shouldBeActive) {
        updated.add(counter);
        continue;
      }
      final changed = counter.copyWith(isActivated: shouldBeActive);
      await tallyDatabaseHelper.updateTally(dbTally: changed);
      updated.add(changed);
    }
    emit(state.copyWith(allCounters: updated));
    return updated;
  }

  Future<void> _toggleCounterActivation(
    TallyToggleCounterActivationEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    if (event.activate) {
      await _activate(state, event.counter, emit);
      return;
    }

    final updated = <DbTally>[];
    for (final counter in state.allCounters) {
      if (counter.id == event.counter.id && counter.isActivated) {
        final changed = counter.copyWith(isActivated: false);
        await tallyDatabaseHelper.updateTally(dbTally: changed);
        updated.add(changed);
      } else {
        updated.add(counter);
      }
    }
    emit(state.copyWith(allCounters: updated));
  }

  Future<void> _moveActive(int step, Emitter<TallyState> emit) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeIndex = state.allCounters.indexWhere((x) => x.isActivated);
    if (activeIndex == -1) return;

    final next = state.allCounters[(activeIndex + step) % state.allCounters.length];
    await _activate(state, next, emit);
  }

  Future<void> _nextCounter(TallyNextCounterEvent event, Emitter<TallyState> emit) =>
      _moveActive(1, emit);

  Future<void> _previousCounter(TallyPreviousCounterEvent event, Emitter<TallyState> emit) =>
      _moveActive(-1, emit);

  Future<void> _randomCounter(
    TallyRandomCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;
    final next = pickNextCounter(state.allCounters, TallyIterationMode.shuffle);
    if (next != null) await _activate(state, next, emit);
  }

  /// The counter auto-advance goes to next, or null when there is nowhere to go.
  /// With [audioOnly] counters without a recording are skipped.
  @visibleForTesting
  static DbTally? pickNextCounter(
    List<DbTally> counters,
    TallyIterationMode mode, {
    bool audioOnly = false,
    Random? random,
  }) {
    final activeIndex = counters.indexWhere((x) => x.isActivated);
    if (activeIndex == -1 || mode == TallyIterationMode.none) return null;

    final candidates = <DbTally>[];
    for (int step = 1; step < counters.length; step++) {
      // Walks forward from the active one, so the first candidate is the circular next.
      final counter = counters[(activeIndex + step) % counters.length];
      if (!audioOnly || counter.hasAudio) candidates.add(counter);
    }
    if (candidates.isEmpty) return null;

    return switch (mode) {
      TallyIterationMode.circular => candidates.first,
      TallyIterationMode.shuffle => candidates[(random ?? Random()).nextInt(candidates.length)],
      TallyIterationMode.none => null,
    };
  }

  Future<void> _resetAllCounters(
    TallyResetAllCountersEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final updatedCounters = List<DbTally>.from(
      state.allCounters,
    ).map((x) => x.copyWith(count: 0)).toList();

    await tallyDatabaseHelper.updateTallies(dbTallies: updatedCounters);

    emit(state.copyWith(allCounters: updatedCounters));
  }

  /// Puts back the counts of [TallyRestoreCountersEvent.counters] (undo of a reset).
  Future<void> _restoreCounters(
    TallyRestoreCountersEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final byId = {for (final c in event.counters) c.id: c};
    final updated = [
      for (final counter in state.allCounters)
        if (byId[counter.id] case final old?) counter.copyWith(count: old.count) else counter,
    ];

    await tallyDatabaseHelper.updateTallies(dbTallies: updated);
    emit(state.copyWith(allCounters: updated));
  }

  Future<void> _resetActiveCounter(
    TallyResetActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final activeCounter = state.activeCounter;
    if (activeCounter == null) return;

    add(TallyEditCounterEvent(counter: activeCounter.copyWith(count: 0)));
  }

  /// Counts one. When auto-advance is on and this count is the one the counter hands
  /// over on (every count, or the end of a cycle), the next counter is activated a
  /// moment later so the new number can be seen first.
  Future<void> _increaseActiveCounter(
    TallyIncreaseActiveCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) {
      event.completer?.complete(null);
      return;
    }
    final activeCounter = state.activeCounter;
    if (activeCounter == null) {
      event.completer?.complete(null);
      return;
    }

    final counted = activeCounter.copyWith(
      count: activeCounter.count + 1,
      lastUpdate: DateTime.now(),
    );
    await tallyDatabaseHelper.updateTally(dbTally: counted);

    final advance =
        state.iterationMode != TallyIterationMode.none &&
        state.advanceTrigger.shouldAdvance(counted);

    emit(
      state.copyWith(
        allCounters: [for (final c in state.allCounters) c.id == counted.id ? counted : c],
        loadingIteration: advance,
      ),
    );

    effectsManager.playProgressEffects(zikrCompleted: counted.isAtCycleEnd);

    if (advance) {
      Future.delayed(advanceDelay, () {
        if (!isClosed) {
          add(TallyIterateEvent(completer: event.completer, audioOnly: event.audioOnly));
        }
      });
    } else {
      event.completer?.complete(counted);
    }
  }

  Future<void> _decreaseActiveCounter(
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

  Future<void> _toggleIterationMode(
    TallyToggleIterationModeEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final nextModeIndex = (state.iterationMode.index + 1) % TallyIterationMode.values.length;

    final TallyIterationMode nextMode = TallyIterationMode.values[nextModeIndex];

    tallyRepo.saveIterationMode(nextMode);

    emit(state.copyWith(iterationMode: nextMode));
  }

  Future<void> _setIterationMode(
    TallySetIterationModeEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    tallyRepo.saveIterationMode(event.mode);
    emit(state.copyWith(iterationMode: event.mode));
  }

  Future<void> _setAdvanceTrigger(
    TallySetAdvanceTriggerEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    tallyRepo.saveAdvanceTrigger(event.trigger);
    emit(state.copyWith(advanceTrigger: event.trigger));
  }

  /// Hands over to the next counter (circular or shuffle).
  Future<void> _iterate(
    TallyIterateEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) {
      event.completer?.complete(null);
      return;
    }

    final next = pickNextCounter(
      state.allCounters,
      state.iterationMode,
      audioOnly: event.audioOnly,
    );

    if (next != null) await _activate(state, next, emit);

    final current = this.state;
    if (current is TallyLoadedState) emit(current.copyWith(loadingIteration: false));

    final after = this.state;
    event.completer?.complete(after is TallyLoadedState ? after.activeCounter : null);
  }

  @override
  Future<void> close() {
    _volumeSubscription?.cancel();
    volumeButtonManager.dispose();
    return super.close();
  }
}
