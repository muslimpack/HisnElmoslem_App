import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AlarmsBloc alarmsBloc;
  late final StreamSubscription alarmSubscription;
  HomeBloc(this.alarmsBloc) : super(HomeLoadingState()) {
    alarmSubscription = alarmsBloc.stream.listen(_onAlarmBlocChanged);

    _initHandlers();
  }
  void _initHandlers() {
    on<HomeStartEvent>(_start);
    on<HomeToggleSearchEvent>(_toggleSearch);
    on<HomeSearchEvent>(_search);
    on<HomeBookmarkTitleEvent>(_bookmarkTitle);
    on<HomeUnBookmarkTitleEvent>(_unBookmarkTitle);
    on<HomeBookmarkContentEvent>(_bookmarkContent);
    on<HomeUnBookmarkContentEvent>(_unBookmarkContent);
    on<HomeUpdateAlarmsEvent>(_updateAlarms);
  }

  Future<void> _onAlarmBlocChanged(AlarmsState alarmState) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    final alarmStateHolded = alarmState;
    if (alarmStateHolded is! AlarmsLoadedState) return;

    add(HomeUpdateAlarmsEvent(alarms: alarmStateHolded.alarms));
  }

  FutureOr<void> _updateAlarms(
    HomeUpdateAlarmsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
    final Map<int, DbAlarm> alarms = {
      for (final alarm in event.alarms) alarm.id: alarm,
    };
    emit(state.copyWith(alarms: alarms));
  }

  FutureOr<void> _start(
    HomeStartEvent event,
    Emitter<HomeState> emit,
  ) async {}

  FutureOr<void> _toggleSearch(
    HomeToggleSearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    emit(state.copyWith(isSearching: event.isSearching));
  }

  FutureOr<void> _search(
    HomeSearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
  }

  FutureOr<void> _bookmarkTitle(
    HomeBookmarkTitleEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
  }

  FutureOr<void> _unBookmarkTitle(
    HomeUnBookmarkTitleEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
  }

  FutureOr<void> _bookmarkContent(
    HomeBookmarkContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
  }

  FutureOr<void> _unBookmarkContent(
    HomeUnBookmarkContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;
  }

  @override
  Future<void> close() {
    alarmSubscription.cancel();
    return super.close();
  }
}
