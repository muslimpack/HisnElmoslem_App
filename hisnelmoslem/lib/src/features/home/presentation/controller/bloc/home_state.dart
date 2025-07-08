// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<int> dashboardArrangement;
  final List<DbTitle> titles;
  final List<int> bookmarkedTitlesIds;
  final List<DbContent> bookmarkedContents;
  final List<TitlesFreqEnum> freqFilters;
  final bool isSearching;

  List<DbTitle> get allTitles {
    return titles.where((x) => freqFilters.validate(x.freq)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<DbTitle> get bookmarkedTitles {
    return titles.where((x) => bookmarkedTitlesIds.contains(x.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  const HomeLoadedState({
    required this.dashboardArrangement,
    required this.titles,
    required this.bookmarkedContents,
    required this.freqFilters,
    required this.isSearching,
    required this.bookmarkedTitlesIds,
  });

  HomeLoadedState copyWith({
    List<int>? dashboardArrangement,
    List<DbTitle>? titles,
    List<DbContent>? bookmarkedContents,
    List<int>? bookmarkedTitlesIds,
    List<TitlesFreqEnum>? freqFilters,
    bool? isSearching,
  }) {
    return HomeLoadedState(
      dashboardArrangement: dashboardArrangement ?? this.dashboardArrangement,
      titles: titles ?? this.titles,
      bookmarkedContents: bookmarkedContents ?? this.bookmarkedContents,
      freqFilters: freqFilters ?? this.freqFilters,
      isSearching: isSearching ?? this.isSearching,
      bookmarkedTitlesIds: bookmarkedTitlesIds ?? this.bookmarkedTitlesIds,
    );
  }

  @override
  List<Object> get props {
    return [
      titles,
      isSearching,
      dashboardArrangement,
      freqFilters,
      bookmarkedContents,
      bookmarkedTitlesIds,
    ];
  }
}
