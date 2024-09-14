import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AlarmsBloc alarmsBloc;
  late final StreamSubscription alarmSubscription;
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  HomeBloc(this.alarmsBloc) : super(HomeLoadingState()) {
    alarmSubscription = alarmsBloc.stream.listen(_onAlarmBlocChanged);

    _initHandlers();
  }
  void _initHandlers() {
    on<HomeStartEvent>(_start);
    on<HomeToggleSearchEvent>(_toggleSearch);

    on<HomeBookmarkTitleEvent>(_bookmarkTitle);
    on<HomeUnBookmarkTitleEvent>(_unBookmarkTitle);
    on<HomeBookmarkContentEvent>(_bookmarkContent);
    on<HomeUnBookmarkContentEvent>(_unBookmarkContent);
    on<HomeUpdateBookmarkedContentsEvent>(_updateBookmarkedContents);
    on<HomeUpdateAlarmsEvent>(_updateAlarms);
    on<HomeToggleDrawerEvent>(_toggleDrawer);
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
  ) async {
    final titles = await azkarDatabaseHelper.getAllTitles();
    final alarms = await alarmDatabaseHelper.getAlarms();
    final bookmarkedContents = await azkarDatabaseHelper.getFavouriteContents();

    emit(
      HomeLoadedState(
        titles: titles,
        alarms: {for (final alarm in alarms) alarm.id: alarm},
        bookmarkedContents: bookmarkedContents,
        isSearching: false,
      ),
    );
  }

  FutureOr<void> _toggleSearch(
    HomeToggleSearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    emit(
      state.copyWith(
        isSearching: event.isSearching,
      ),
    );
  }

  FutureOr<void> _bookmarkTitle(
    HomeBookmarkTitleEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    await azkarDatabaseHelper.addTitleToFavourite(dbTitle: event.title);

    final titles = List<DbTitle>.of(state.titles).map((e) {
      if (e.id == event.title.id) {
        return event.title.copyWith(favourite: true);
      }
      return e;
    }).toList();

    emit(state.copyWith(titles: titles));
  }

  FutureOr<void> _unBookmarkTitle(
    HomeUnBookmarkTitleEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    await azkarDatabaseHelper.addTitleToFavourite(dbTitle: event.title);

    final titles = List<DbTitle>.of(state.titles).map((e) {
      if (e.id == event.title.id) {
        return event.title.copyWith(favourite: false);
      }
      return e;
    }).toList();

    emit(state.copyWith(titles: titles));
  }

  FutureOr<void> _bookmarkContent(
    HomeBookmarkContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    await azkarDatabaseHelper.addContentToFavourite(dbContent: event.content);

    add(HomeUpdateBookmarkedContentsEvent());
  }

  FutureOr<void> _unBookmarkContent(
    HomeUnBookmarkContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    await azkarDatabaseHelper.removeContentFromFavourite(
      dbContent: event.content,
    );

    add(HomeUpdateBookmarkedContentsEvent());
  }

  FutureOr<void> _updateBookmarkedContents(
    HomeUpdateBookmarkedContentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    final bookmarkedContents = await azkarDatabaseHelper.getFavouriteContents();
    emit(state.copyWith(bookmarkedContents: bookmarkedContents));
  }

  FutureOr<void> _toggleDrawer(
    HomeToggleDrawerEvent event,
    Emitter<HomeState> emit,
  ) async {
    zoomDrawerController.toggle?.call();
  }

  @override
  Future<void> close() {
    alarmSubscription.cancel();
    return super.close();
  }
}
