import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TextEditingController searchController = TextEditingController();
  final HomeBloc homeBloc;
  late final StreamSubscription homeBlocSubscription;
  SearchCubit(this.homeBloc)
    : super(const SearchState(searchText: "", allTitles: [])) {
    _onHomeBlocChange(homeBloc.state);
    homeBlocSubscription = homeBloc.stream.listen(_onHomeBlocChange);
  }

  void _onHomeBlocChange(HomeState homeState) {
    if (homeState is! HomeLoadedState) return;

    emit(state.copyWith(allTitles: homeState.titles));
  }

  Future<void> erase() async {
    searchController.clear();
    emit(state.copyWith(searchText: ""));
  }

  Future<void> search(String searchText) async {
    emit(state.copyWith(searchText: searchText));
  }

  @override
  Future<void> close() {
    homeBlocSubscription.cancel();
    return super.close();
  }
}
