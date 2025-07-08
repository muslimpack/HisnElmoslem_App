part of 'bookmark_bloc.dart';

sealed class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object> get props => [];
}

final class BookmarkLoadingState extends BookmarkState {}

final class BookmarkLoadedState extends BookmarkState {
  final List<int> bookmarkedTitlesIds;
  final List<DbContent> bookmarkedContents;

  const BookmarkLoadedState({
    required this.bookmarkedTitlesIds,
    required this.bookmarkedContents,
  });

  @override
  List<Object> get props => [bookmarkedTitlesIds, bookmarkedContents];

  BookmarkLoadedState copyWith({
    List<int>? bookmarkedTitlesIds,
    List<DbContent>? bookmarkedContents,
  }) {
    return BookmarkLoadedState(
      bookmarkedTitlesIds: bookmarkedTitlesIds ?? this.bookmarkedTitlesIds,
      bookmarkedContents: bookmarkedContents ?? this.bookmarkedContents,
    );
  }
}
