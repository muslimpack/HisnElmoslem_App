part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<DbTitle> titles;
  final List<DbTitle> titlesToView;
  final Map<int, DbAlarm> alarms;
  final List<DbContent> bookmarkedContents;
  final bool isSearching;

  List<DbTitle> get bookmarkedTitles =>
      titlesToView.where((x) => x.favourite).toList();

  const HomeLoadedState({
    required this.titles,
    required this.titlesToView,
    required this.alarms,
    required this.bookmarkedContents,
    required this.isSearching,
  });

  HomeLoadedState copyWith({
    List<DbTitle>? titles,
    List<DbTitle>? titlesToView,
    Map<int, DbAlarm>? alarms,
    List<DbContent>? bookmarkedContents,
    bool? isSearching,
  }) {
    return HomeLoadedState(
      titles: titles ?? this.titles,
      titlesToView: titlesToView ?? this.titlesToView,
      alarms: alarms ?? this.alarms,
      bookmarkedContents: bookmarkedContents ?? this.bookmarkedContents,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props {
    return [
      titles,
      titlesToView,
      alarms,
      bookmarkedContents,
      isSearching,
    ];
  }
}
