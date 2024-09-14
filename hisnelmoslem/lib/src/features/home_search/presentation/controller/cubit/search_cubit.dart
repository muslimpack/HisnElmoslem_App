import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TextEditingController searchController = TextEditingController();
  SearchCubit()
      : super(
          const SearchState(
            searchText: "",
            titlesToView: [],
          ),
        );

  FutureOr<void> erase() async {
    searchController.clear();
  }

  FutureOr<void> search(String searchText) async {
    if (searchText.isEmpty) {
      emit(
        state.copyWith(
          searchText: searchText,
          titlesToView: [],
        ),
      );
      return;
    }

    final titlesToView = state.titlesToView.where((zikr) {
      return zikr.name.removeDiacritics.contains(searchText);
    }).toList();

    emit(
      state.copyWith(
        searchText: searchText,
        titlesToView: titlesToView,
      ),
    );
  }
}
