import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_card.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_zikr_card.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/title_card.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_for.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_results.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_app_bar.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_content_card.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_filters_dialog.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_for_bar.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_result_viewer.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Scaffold(
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                const SearchAppBar(),
                const SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [SearchForBar(), SearchFiltersButton()],
                  ),
                ),
              ];
            },
            body: state is! SearchLoadedState
                ? const Loading()
                : switch (state.searchFor) {
                    SearchFor.title => SearchResultViewer<TitleSearchResult>(
                      pagingController: sl<SearchCubit>().titlePagingController,
                      itemBuilder: (context, item, index) {
                        return switch (item) {
                          OriginalTitleResult(:final title) => TitleCard(dbTitle: title),
                          CustomTitleResult(:final title) => CustomTitleCard(title: title),
                        };
                      },
                    ),
                    SearchFor.content => SearchResultViewer<ContentSearchResult>(
                      pagingController: sl<SearchCubit>().contentPagingController,
                      itemBuilder: (context, item, index) {
                        return switch (item) {
                          OriginalContentResult(:final content) => SearchContentCard(
                            index: index,
                            zikr: content,
                            searchText: state.searchText,
                          ),
                          CustomZikrResult(:final zikr) => CustomZikrCard(zikr: zikr),
                        };
                      },
                    ),
                  },
          ),
        );
      },
    );
  }
}
