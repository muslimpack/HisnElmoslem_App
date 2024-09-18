// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';

part 'tally_event.dart';
part 'tally_state.dart';

class TallyBloc extends Bloc<TallyEvent, TallyState> {
  final TallyDatabaseHelper tallyDatabaseHelper;
  final EffectsManager effectsManager;
  final VolumeButtonManager volumeButtonManager;
  TallyBloc(
    this.tallyDatabaseHelper,
    this.effectsManager,
    this.volumeButtonManager,
  ) : super(TallyLoadingState()) {
    _initHandlers();

    volumeButtonManager.toggleActivation(
      activate: sl<AppSettingsRepo>().praiseWithVolumeKeys,
    );

    volumeButtonManager.listen(
      onVolumeUpPressed: () => add(TallyIncreaseActiveCounterEvent()),
      onVolumeDownPressed: () => add(TallyIncreaseActiveCounterEvent()),
    );
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
        iterationMode: TallyIterationMode.none,
        loadingIteration: false,
      ),
    );
  }

  FutureOr<void> _addCounter(
    TallyAddCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final counterToAdd = event.counter.copyWith(
      lastUpdate: DateTime.now(),
      created: DateTime.now(),
    );

    final counterId =
        await tallyDatabaseHelper.addNewTally(dbTally: counterToAdd);

    final updatedCounters = List<DbTally>.from(state.allCounters)
      ..add(counterToAdd.copyWith(id: counterId));

    emit(state.copyWith(allCounters: updatedCounters));
  }

  FutureOr<void> _editCounter(
    TallyEditCounterEvent event,
    Emitter<TallyState> emit,
  ) async {
    final state = this.state;
    if (state is! TallyLoadedState) return;

    final counterToEdit = event.counter.copyWith(lastUpdate: DateTime.now());

    await tallyDatabaseHelper.updateTally(
      dbTally: counterToEdit,
    );

    final updatedCounters =
        List<DbTally>.from(state.allCounters).map((counter) {
      if (counter.id == counterToEdit.id) {
        return counterToEdit;
      }
      return counter;
    }).toList();

    emit(
      state.copyWith(
        allCounters: updatedCounters,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 350));
    event.completer?.complete();
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
    for (int i = 0; i < updatedCounters.length; i++) {
      final counter = updatedCounters[i];
      final DbTally counterToSet;
      if (counter.id == event.counter.id) {
        counterToSet = counter.copyWith(isActivated: event.activate);
      } else {
        counterToSet = counter.copyWith(isActivated: false);
      }
      updatedCounters[i] = counterToSet;
      await tallyDatabaseHelper.updateTally(
        dbTally: counterToSet,
      );
    }

    emit(
      state.copyWith(
        allCounters: updatedCounters,
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

    add(
      TallyToggleCounterActivationEvent(
        counter: nextCounter,
        activate: true,
      ),
    );
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
    add(
      TallyToggleCounterActivationEvent(
        counter: previousCounter,
        activate: true,
      ),
    );
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
    add(
      TallyToggleCounterActivationEvent(
        counter: randomCounter,
        activate: true,
      ),
    );
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

    final completer = Completer<void>();
    if (state.iterationMode != TallyIterationMode.none) {
      emit(state.copyWith(loadingIteration: true));
    }
    add(
      TallyEditCounterEvent(
        counter: activeCounter.copyWith(count: activeCounter.count + 1),
        completer: completer,
      ),
    );

    if (activeCounter.count % state.resetEvery == state.resetEvery - 1) {
      effectsManager.playZikrEffects();
    } else {
      effectsManager.playPraiseEffects();
    }

    await completer.future;

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

    emit(state.copyWith(loadingIteration: false));
  }

  @override
  Future<void> close() async {
    volumeButtonManager.dispose();
    return super.close();
  }
}
