import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final HisnDBHelper hisnDBHelper;
  BookmarkBloc(this.hisnDBHelper) : super(BookmarkLoadingState()) {
    on<BookmarkStartEvent>(_start);
    on<BookmarkToggleTitleBookmarkEvent>(_bookmarkTitle);
    on<BookmarkToggleContentBookmarkEvent>(_bookmarkContent);
    on<BookmarkUpdateBookmarkedContentsEvent>(_updateBookmarkedContents);
  }

  Future<void> _start(
    BookmarkStartEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    final bookmarkedContents = await hisnDBHelper.getFavouriteContents();
    final bookmarkedTitlesIds = await hisnDBHelper.getAllFavoriteTitles();

    emit(
      BookmarkLoadedState(
        bookmarkedTitlesIds: bookmarkedTitlesIds,
        bookmarkedContents: bookmarkedContents,
      ),
    );
  }

  Future<void> _bookmarkTitle(
    BookmarkToggleTitleBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    hisnPrint("object");
    final state = this.state;
    if (state is! BookmarkLoadedState) return;

    if (event.bookmark) {
      await hisnDBHelper.addTitleToFavourite(titleId: event.titleId);
    } else {
      await hisnDBHelper.deleteTitleFromFavourite(titleId: event.titleId);
    }

    final bookmarkedTitlesIds = await hisnDBHelper.getAllFavoriteTitles();

    emit(state.copyWith(bookmarkedTitlesIds: bookmarkedTitlesIds));
  }

  Future<void> _bookmarkContent(
    BookmarkToggleContentBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    final state = this.state;
    if (state is! BookmarkLoadedState) return;

    if (event.bookmark) {
      await hisnDBHelper.addContentToFavourite(dbContent: event.content);
    } else {
      await hisnDBHelper.removeContentFromFavourite(dbContent: event.content);
    }

    add(BookmarkUpdateBookmarkedContentsEvent());
  }

  Future<void> _updateBookmarkedContents(
    BookmarkUpdateBookmarkedContentsEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    final state = this.state;
    if (state is! BookmarkLoadedState) return;

    final bookmarkedContents = await hisnDBHelper.getFavouriteContents();
    emit(state.copyWith(bookmarkedContents: bookmarkedContents));
  }
}
