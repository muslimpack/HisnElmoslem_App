// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String searchText;
  final List<DbTitle> titlesToView;

  const SearchState({required this.searchText, required this.titlesToView});

  SearchState copyWith({
    String? searchText,
    List<DbTitle>? titlesToView,
  }) {
    return SearchState(
      searchText: searchText ?? this.searchText,
      titlesToView: titlesToView ?? this.titlesToView,
    );
  }

  @override
  List<Object> get props => [searchText, titlesToView];
}
