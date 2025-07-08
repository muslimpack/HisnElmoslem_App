import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter_list_extension.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/presentation/controller/cubit/azkar_filters_cubit.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/titles_freq_enum.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AlarmsBloc alarmsBloc;
  final BookmarkBloc bookmarkBloc;
  final AzkarFiltersCubit zikrFiltersCubit;
  late final StreamSubscription alarmSubscription;
  late final StreamSubscription filterSubscription;
  late final StreamSubscription bookmarkSubscription;
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  final AlarmDatabaseHelper alarmDatabaseHelper;
  final AppSettingsRepo appSettingsRepo;
  final HisnDBHelper hisnDBHelper;
  HomeBloc(
    this.alarmsBloc,
    this.bookmarkBloc,
    this.alarmDatabaseHelper,
    this.hisnDBHelper,
    this.appSettingsRepo,
    this.zikrFiltersCubit,
  ) : super(HomeLoadingState()) {
    alarmSubscription = alarmsBloc.stream.listen(_onAlarmBlocChanged);
    filterSubscription = zikrFiltersCubit.stream.listen(
      _onZikrFilterCubitChanged,
    );
    bookmarkSubscription = bookmarkBloc.stream.listen(_onBookmarkChanged);

    _initHandlers();
  }
  void _initHandlers() {
    on<HomeStartEvent>(_start);
    on<HomeToggleSearchEvent>(_toggleSearch);

    on<HomeUpdateAlarmsEvent>(_updateAlarms);
    on<HomeToggleDrawerEvent>(_toggleDrawer);
    on<HomeDashboardReorderedEvent>(_onDashboardReorded);

    on<HomeToggleFilterEvent>(_onFilterToggled);
    on<HomeFiltersChangeEvent>(_filtersChanged);
    on<HomeBookmarksChangeEvent>(_bookmarkChanged);
  }

  Future<void> _onAlarmBlocChanged(AlarmsState alarmState) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    if (alarmState is! AlarmsLoadedState) return;

    add(HomeUpdateAlarmsEvent(alarms: alarmState.alarms));
  }

  Future<void> _updateAlarms(
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

  Future<void> _start(HomeStartEvent event, Emitter<HomeState> emit) async {
    final filters = zikrFiltersCubit.state.filters;

    final dbTitles = await hisnDBHelper.getAllTitles();
    final List<DbTitle> filtered = await applyFiltersOnTitels(
      dbTitles,
      zikrFilters: filters,
    );

    final alarms = await alarmDatabaseHelper.getAlarms();

    final azkarFromDB = await hisnDBHelper.getFavouriteContents();
    final filteredAzkar = filters.getFilteredZikr(azkarFromDB);
    final bookmarkedTitlesIds = await hisnDBHelper.getAllFavoriteTitles();

    emit(
      HomeLoadedState(
        titles: filtered,
        alarms: {for (final alarm in alarms) alarm.titleId: alarm},
        bookmarkedContents: filteredAzkar,
        isSearching: false,
        dashboardArrangement: appSettingsRepo.dashboardArrangement,
        freqFilters: appSettingsRepo.getTitlesFreqFilterStatus,
        bookmarkedTitlesIds: bookmarkedTitlesIds,
      ),
    );
  }

  Future<void> _toggleSearch(
    HomeToggleSearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    emit(state.copyWith(isSearching: event.isSearching));
  }

  Future<void> _toggleDrawer(
    HomeToggleDrawerEvent event,
    Emitter<HomeState> emit,
  ) async {
    zoomDrawerController.toggle?.call();
  }

  Future<void> _onDashboardReorded(
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
    filterSubscription.cancel();
    bookmarkSubscription.cancel();
    return super.close();
  }

  Future<void> _onFilterToggled(
    HomeToggleFilterEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    /// Handle freq change
    final List<TitlesFreqEnum> newFreq = List.of(state.freqFilters);
    if (newFreq.contains(event.filter)) {
      newFreq.remove(event.filter);
    } else {
      newFreq.add(event.filter);
    }

    await appSettingsRepo.setTitlesFreqFilterStatus(newFreq);

    emit(state.copyWith(freqFilters: newFreq));
  }

  Future<List<DbTitle>> applyFiltersOnTitels(
    List<DbTitle> titles, {
    List<Filter>? zikrFilters,
  }) async {
    final List<DbTitle> titlesToSet = [];

    final List<Filter> filters = zikrFilters ?? zikrFiltersCubit.state.filters;
    for (var i = 0; i < titles.length; i++) {
      final title = titles[i];
      final azkarFromDB = await hisnDBHelper.getContentsByTitleId(
        titleId: title.id,
      );
      final azkarToSet = filters.getFilteredZikr(azkarFromDB);
      if (azkarToSet.isNotEmpty) titlesToSet.add(title);
    }

    return titlesToSet;
  }

  Future<void> _onZikrFilterCubitChanged(AzkarFiltersState state) async {
    add(HomeFiltersChangeEvent(state.filters));
  }

  Future<void> _filtersChanged(
    HomeFiltersChangeEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    final dbTitles = await hisnDBHelper.getAllTitles();
    final List<DbTitle> filtered = await applyFiltersOnTitels(
      dbTitles,
      zikrFilters: event.filters,
    );

    final azkarFromDB = await hisnDBHelper.getFavouriteContents();
    final filteredAzkar = event.filters.getFilteredZikr(azkarFromDB);

    emit(state.copyWith(titles: filtered, bookmarkedContents: filteredAzkar));
  }

  void _onBookmarkChanged(BookmarkState bState) {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    final bookmarkState = bState;
    if (bookmarkState is! BookmarkLoadedState) return;

    add(
      HomeBookmarksChangeEvent(
        bookmarkedTitlesIds: bookmarkState.bookmarkedTitlesIds,
        bookmarkedContents: bookmarkState.bookmarkedContents,
      ),
    );
  }

  Future<void> _bookmarkChanged(
    HomeBookmarksChangeEvent event,
    Emitter<HomeState> emit,
  ) async {
    final state = this.state;
    if (state is! HomeLoadedState) return;

    emit(
      state.copyWith(
        bookmarkedTitlesIds: List.of(event.bookmarkedTitlesIds),
        bookmarkedContents: List.of(event.bookmarkedContents),
      ),
    );
  }
}
