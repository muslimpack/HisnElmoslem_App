import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AlarmsBloc alarmsBloc;
  late final StreamSubscription alarmSubscription;
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  final AlarmDatabaseHelper alarmDatabaseHelper;
  final AppSettingsRepo appSettingsRepo;
  final AzkarDatabaseHelper azkarDatabaseHelper;
  HomeBloc(
    this.alarmsBloc,
    this.alarmDatabaseHelper,
    this.azkarDatabaseHelper,
    this.appSettingsRepo,
  ) : super(HomeLoadingState()) {
    alarmSubscription = alarmsBloc.stream.listen(_onAlarmBlocChanged);

    _initHandlers();
  }
  void _initHandlers() {
    on<HomeStartEvent>(_start);
    on<HomeToggleSearchEvent>(_toggleSearch);

    on<HomeToggleTitleBookmarkEvent>(_bookmarkTitle);
    on<HomeToggleContentBookmarkEvent>(_bookmarkContent);
    on<HomeUpdateBookmarkedContentsEvent>(_updateBookmarkedContents);
    on<HomeUpdateAlarmsEvent>(_updateAlarms);
    on<HomeToggleDrawerEvent>(_toggleDrawer);
    on<HomeDashboardReorderedEvent>(_onDashboardReorded);
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
      for (final alarm in event.alarms) alarm.titleId: alarm,
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
        alarms: {for (final alarm in alarms) alarm.titleId: alarm},
        bookmarkedContents: bookmarkedContents,
        isSearching: false,
        dashboardArrangement: appSettingsRepo.dashboardArrangement,
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
    HomeToggleTitleBookmarkEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    if (event.bookmark) {
      await azkarDatabaseHelper.addTitleToFavourite(dbTitle: event.title);
    } else {
      await azkarDatabaseHelper.deleteTitleFromFavourite(dbTitle: event.title);
    }

    final titles = List<DbTitle>.of(state.titles).map((e) {
      if (e.id == event.title.id) {
        return event.title.copyWith(favourite: event.bookmark);
      }
      return e;
    }).toList();

    emit(state.copyWith(titles: titles));
  }

  FutureOr<void> _bookmarkContent(
    HomeToggleContentBookmarkEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    if (event.bookmark) {
      await azkarDatabaseHelper.addContentToFavourite(dbContent: event.content);
    } else {
      await azkarDatabaseHelper.removeContentFromFavourite(
        dbContent: event.content,
      );
    }

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

  FutureOr<void> _onDashboardReorded(
    HomeDashboardReorderedEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    final List<int> listToSet = List<int>.from(state.dashboardArrangement);

    int newIndex = event.newIndex;

    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }
    final int item = listToSet.removeAt(event.oldIndex);
    listToSet.insert(newIndex, item);

    appSettingsRepo.changeDashboardArrangement(listToSet);

    emit(state.copyWith(dashboardArrangement: listToSet));
  }

  @override
  Future<void> close() {
    alarmSubscription.cancel();
    return super.close();
  }
}
