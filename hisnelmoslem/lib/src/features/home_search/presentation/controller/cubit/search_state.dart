// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_cubit.dart';

class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchLoadedState extends SearchState {
  final String searchText;
  final SearchType searchType;
  final SearchFor searchFor;
  final int searchResultCount;

  int get pageSize => 10;

  const SearchLoadedState({
    required this.searchText,
    required this.searchType,
    required this.searchFor,
    required this.searchResultCount,
  });

  @override
  List<Object> get props => [
    searchText,
    searchType,
    searchFor,
    searchResultCount,
  ];

  SearchLoadedState copyWith({
    String? searchText,
    SearchType? searchType,
    SearchFor? searchFor,
    int? searchResultCount,
  }) {
    return SearchLoadedState(
      searchText: searchText ?? this.searchText,
      searchType: searchType ?? this.searchType,
      searchFor: searchFor ?? this.searchFor,
      searchResultCount: searchResultCount ?? this.searchResultCount,
    );
  }
}
