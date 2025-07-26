import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/azakr_filters_repo.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_for.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/home_search/domain/repository/search_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TextEditingController searchController = TextEditingController();
  late final PagingController<int, DbTitle> titlePagingController;
  late final PagingController<int, DbContent> contentPagingController;

  ///
  final HomeBloc homeBloc;
  final AzkarFiltersRepo zikrFilterStorage;
  final HisnDBHelper azkarDBHelper;
  final SearchRepo searchRepo;
  SearchCubit(
    this.homeBloc,
    this.zikrFilterStorage,
    this.azkarDBHelper,
    this.searchRepo,
  ) : super(const SearchLoadingState()) {
    homeBloc.stream.listen((event) {
      final homeBlocState = homeBloc.state;
      if (homeBlocState is! HomeLoadedState) return;
      final state = this.state;
      if (state is! SearchLoadedState) return;
    });

    titlePagingController = PagingController(firstPageKey: 0)
      ..addPageRequestListener(fetchPage);

    contentPagingController = PagingController(firstPageKey: 0)
      ..addPageRequestListener(fetchPage);

    searchController.addListener(() {
      EasyDebounce.debounce('search', const Duration(milliseconds: 500), () {
        updateSearchText(searchController.text);
      });
    });
  }

  Future start() async {
    final state = SearchLoadedState(
      searchText: "",
      searchType: searchRepo.searchType,
      searchFor: searchRepo.searchFor,
      searchResultCount: 0,
    );

    emit(state);
  }

  Future fetchPage(int pageKey) async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    switch (state.searchFor) {
      case SearchFor.title:
        searchTitleByName(pageKey, state);
      case SearchFor.content:
        searchContent(pageKey, state);
    }
  }

  Future searchContent(int offset, SearchLoadedState state) async {
    try {
      final (count, content) = await azkarDBHelper.searchContent(
        searchText: state.searchText,
        searchType: state.searchType,
        limit: state.pageSize,
        offset: offset,
      );

      emit(state.copyWith(searchResultCount: count));

      final isLastPage = content.length < state.pageSize;
      if (isLastPage) {
        contentPagingController.appendLastPage(content);
      } else {
        final nextPageKey = offset + content.length;
        contentPagingController.appendPage(content, nextPageKey);
      }
    } catch (e) {
      contentPagingController.error = e;
    }
  }

  Future searchTitleByName(int offset, SearchLoadedState state) async {
    try {
      final (count, titles) = await azkarDBHelper.searchTitleByName(
        searchText: state.searchText,
        searchType: state.searchType,
        limit: state.pageSize,
        offset: offset,
      );

      emit(state.copyWith(searchResultCount: count));

      final isLastPage = titles.length < state.pageSize;
      if (isLastPage) {
        titlePagingController.appendLastPage(titles);
      } else {
        final nextPageKey = offset + titles.length;
        titlePagingController.appendPage(titles, nextPageKey);
      }
    } catch (e) {
      titlePagingController.error = e;
    }
  }

  ///MARK: Search header
  Future _startNewSearch() async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    switch (state.searchFor) {
      case SearchFor.title:
        titlePagingController.refresh();

      case SearchFor.content:
        contentPagingController.refresh();
    }
  }

  ///MARK: Search text

  Future updateSearchText(String searchText) async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    emit(state.copyWith(searchText: searchText));

    _startNewSearch();
  }

  ///MARK: SearchType
  Future changeSearchType(SearchType searchType) async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    await searchRepo.setSearchType(searchType);

    emit(state.copyWith(searchType: searchType));
    _startNewSearch();
  }

  ///MARK: Search For
  Future changeSearchFor(SearchFor searchFor) async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    await searchRepo.setSearchFor(searchFor);

    emit(state.copyWith(searchFor: searchFor));
    _startNewSearch();
  }

  ///MARK: clear
  Future clear() async {
    final state = this.state;
    if (state is! SearchLoadedState) return;

    searchController.clear();
  }

  @override
  Future<void> close() {
    titlePagingController.dispose();
    contentPagingController.dispose();
    searchController.dispose();
    EasyDebounce.cancel('search');
    return super.close();
  }
}
