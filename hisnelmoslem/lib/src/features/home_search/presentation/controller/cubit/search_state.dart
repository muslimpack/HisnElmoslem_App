// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String searchText;
  final List<DbTitle> allTitles;

  const SearchState({required this.searchText, required this.allTitles});

  List<DbTitle> get searchedTitles {
    if (searchText.isEmpty) return [];
    return allTitles.where((zikr) {
      return zikr.name.removeDiacritics.contains(searchText);
    }).toList();
  }

  SearchState copyWith({
    String? searchText,
    List<DbTitle>? allTitles,
  }) {
    return SearchState(
      searchText: searchText ?? this.searchText,
      allTitles: allTitles ?? this.allTitles,
    );
  }

  @override
  List<Object> get props => [searchText, allTitles];
}
