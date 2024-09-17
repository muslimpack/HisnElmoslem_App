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

class HomeToggleTitleBookmarkEvent extends HomeEvent {
  final DbTitle title;
  final bool bookmark;
  const HomeToggleTitleBookmarkEvent({
    required this.title,
    required this.bookmark,
  });

  @override
  List<Object> get props => [title, bookmark];
}

class HomeToggleContentBookmarkEvent extends HomeEvent {
  final DbContent content;
  final bool bookmark;

  const HomeToggleContentBookmarkEvent({
    required this.content,
    required this.bookmark,
  });

  @override
  List<Object> get props => [content, bookmark];
}

class HomeUpdateBookmarkedContentsEvent extends HomeEvent {}

class HomeUpdateAlarmsEvent extends HomeEvent {
  final List<DbAlarm> alarms;

  const HomeUpdateAlarmsEvent({
    required this.alarms,
  });

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
