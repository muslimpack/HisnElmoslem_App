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

class HomeBookmarkTitleEvent extends HomeEvent {
  final DbTitle title;

  const HomeBookmarkTitleEvent({required this.title});

  @override
  List<Object> get props => [title];
}

class HomeUnBookmarkTitleEvent extends HomeEvent {
  final DbTitle title;

  const HomeUnBookmarkTitleEvent({required this.title});

  @override
  List<Object> get props => [title];
}

class HomeBookmarkContentEvent extends HomeEvent {
  final DbContent content;

  const HomeBookmarkContentEvent({
    required this.content,
  });

  @override
  List<Object> get props => [content];
}

class HomeUnBookmarkContentEvent extends HomeEvent {
  final DbContent content;

  const HomeUnBookmarkContentEvent({
    required this.content,
  });

  @override
  List<Object> get props => [content];
}

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
