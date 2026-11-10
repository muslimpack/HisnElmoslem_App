import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/azakr_filters_repo.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_for.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_results.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/home_search/domain/repository/search_repo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  /// The user's custom items are few, so all matches are loaded with the first page.
  static const int _customHitsLimit = 200;

  final TextEditingController searchController = TextEditingController();
  late final PagingController<int, TitleSearchResult> titlePagingController;
  late final PagingController<int, ContentSearchResult> contentPagingController;

  /// How many custom hits were put in front of the first page of the current search.
  /// Later pages subtract it to compute the offset in the original database.
  int _customTitleHitsOnFirstPage = 0;
  int _customContentHitsOnFirstPage = 0;

  ///
  final HomeBloc homeBloc;
  final AzkarFiltersRepo zikrFilterStorage;
  final HisnDBHelper azkarDBHelper;
  final SearchRepo searchRepo;
  final CustomAzkarRepo customAzkarRepo;
  SearchCubit(
    this.homeBloc,
    this.zikrFilterStorage,
    this.azkarDBHelper,
    this.searchRepo,
    this.customAzkarRepo,
  ) : super(const SearchLoadingState()) {
    homeBloc.stream.listen((event) {
      final homeBlocState = homeBloc.state;
      if (homeBlocState is! HomeLoadedState) return;
      final state = this.state;
      if (state is! SearchLoadedState) return;
    });

    titlePagingController = PagingController<int, TitleSearchResult>(
      getNextPageKey: _nextPageKey,
      fetchPage: (pageKey) async {
        final state = this.state;
        if (state is! SearchLoadedState) return [];

        final customHits = <TitleSearchResult>[];
        var customCount = 0;
        if (pageKey == 0) {
          final (count, titles) = await customAzkarRepo.searchTitles(
            state.searchText,
            state.searchType,
            limit: _customHitsLimit,
            offset: 0,
          );
          customCount = count;
          customHits.addAll(titles.map(CustomTitleResult.new));
          _customTitleHitsOnFirstPage = customHits.length;
        }

        final (count, titles) = await azkarDBHelper.searchTitleByName(
          searchText: state.searchText,
          searchType: state.searchType,
          limit: state.pageSize,
          offset: pageKey == 0 ? 0 : pageKey - _customTitleHitsOnFirstPage,
        );

        if (pageKey == 0) {
          emit(state.copyWith(searchResultCount: count + customCount));
        }
        return [...customHits, ...titles.map(OriginalTitleResult.new)];
      },
    );

    contentPagingController = PagingController<int, ContentSearchResult>(
      getNextPageKey: _nextPageKey,
      fetchPage: (pageKey) async {
        final state = this.state;
        if (state is! SearchLoadedState) return [];

        final customHits = <ContentSearchResult>[];
        var customCount = 0;
        if (pageKey == 0) {
          final (count, zikrs) = await customAzkarRepo.searchZikrs(
            state.searchText,
            state.searchType,
            limit: _customHitsLimit,
            offset: 0,
          );
          customCount = count;
          customHits.addAll(zikrs.map(CustomZikrResult.new));
          _customContentHitsOnFirstPage = customHits.length;
        }

        final (count, content) = await azkarDBHelper.searchContent(
          searchText: state.searchText,
          searchType: state.searchType,
          limit: state.pageSize,
          offset: pageKey == 0 ? 0 : pageKey - _customContentHitsOnFirstPage,
        );

        if (pageKey == 0) {
          emit(state.copyWith(searchResultCount: count + customCount));
        }
        return [...customHits, ...content.map(OriginalContentResult.new)];
      },
    );

    searchController.addListener(() {
      EasyDebounce.debounce('search', const Duration(milliseconds: 500), () {
        updateSearchText(searchController.text);
      });
    });
  }

  /// Keys are the number of items already loaded, so a first page that also holds
  /// custom hits simply shifts the following keys.
  int? _nextPageKey(PagingState<int, Object> state) {
    if (state.keys == null) return 0;
    final loadedState = this.state;
    final limit = loadedState is SearchLoadedState ? loadedState.pageSize : 10;
    if (state.pages != null && state.pages!.isNotEmpty && state.pages!.last.length < limit) {
      return null;
    }
    return state.keys!.last + state.pages!.last.length;
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
