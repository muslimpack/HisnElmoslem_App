part of 'bookmark_bloc.dart';

sealed class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object> get props => [];
}

class BookmarkStartEvent extends BookmarkEvent {}

class BookmarkToggleTitleBookmarkEvent extends BookmarkEvent {
  final int titleId;
  final bool bookmark;
  const BookmarkToggleTitleBookmarkEvent({
    required this.titleId,
    required this.bookmark,
  });

  @override
  List<Object> get props => [titleId, bookmark];
}

class BookmarkToggleContentBookmarkEvent extends BookmarkEvent {
  final DbContent content;
  final bool bookmark;

  const BookmarkToggleContentBookmarkEvent({
    required this.content,
    required this.bookmark,
  });

  @override
  List<Object> get props => [content, bookmark];
}

class BookmarkUpdateBookmarkedContentsEvent extends BookmarkEvent {}
