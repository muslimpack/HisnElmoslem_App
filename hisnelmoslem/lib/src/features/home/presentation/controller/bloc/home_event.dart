// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeStartEvent extends HomeEvent {}

class HomeToggleSearchEvent extends HomeEvent {
  final bool isSearching;

  const HomeToggleSearchEvent({required this.isSearching});

  @override
  List<Object> get props => [isSearching];
}

class HomeSearchEvent extends HomeEvent {
  final String searchText;

  const HomeSearchEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}

class HomeUpdateAlarmsEvent extends HomeEvent {
  final List<DbAlarm> alarms;

  const HomeUpdateAlarmsEvent({required this.alarms});

  @override
  List<Object> get props => [alarms];
}

class HomeToggleDrawerEvent extends HomeEvent {
  const HomeToggleDrawerEvent();
}

class HomeDashboardReorderedEvent extends HomeEvent {
  final int oldIndex;
  final int newIndex;
  const HomeDashboardReorderedEvent({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class HomeToggleFilterEvent extends HomeEvent {
  final TitlesFreqEnum filter;

  const HomeToggleFilterEvent(this.filter);

  @override
  List<Object> get props => [filter];
}

class HomeFiltersChangeEvent extends HomeEvent {
  final List<Filter> filters;

  const HomeFiltersChangeEvent(this.filters);

  @override
  List<Object> get props => [filters];
}

class HomeBookmarksChangeEvent extends HomeEvent {
  final List<int> bookmarkedTitlesIds;
  final List<DbContent> bookmarkedContents;
  const HomeBookmarksChangeEvent({
    required this.bookmarkedTitlesIds,
    required this.bookmarkedContents,
  });
  @override
  List<Object> get props => [bookmarkedTitlesIds, bookmarkedContents];
}
