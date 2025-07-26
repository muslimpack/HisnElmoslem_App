import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/no_items_found_indicator_builder.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/no_more_items_indicator_builder.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchResultViewer<T> extends StatelessWidget {
  final PagingController<int, T> pagingController;
  final Widget Function(BuildContext, T, int) itemBuilder;
  const SearchResultViewer({
    super.key,
    required this.pagingController,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is! SearchLoadedState) return const SizedBox.shrink();

        return PagedListView<int, T>(
          pagingController: pagingController,
          // padding: const EdgeInsets.all(15),
          builderDelegate: PagedChildBuilderDelegate<T>(
            animateTransitions: true,
            transitionDuration: const Duration(milliseconds: 500),
            itemBuilder: (context, item, index) =>
                itemBuilder(context, item, index),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: LinearProgressIndicator(),
            ),
            noMoreItemsIndicatorBuilder: (context) =>
                const NoMoreItemsIndicatorBuilder(),
            noItemsFoundIndicatorBuilder: (context) =>
                NoItemsFoundIndicatorBuilder(searchText: state.searchText),
          ),
        );
      },
    );
  }
}
