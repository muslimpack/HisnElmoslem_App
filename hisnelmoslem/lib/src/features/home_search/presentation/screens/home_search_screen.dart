import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_list_view.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';

class HomeSearchScreen extends StatelessWidget {
  const HomeSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState is! HomeLoadedState) {
              return const SizedBox();
            }
            return state.searchedTitles.isEmpty
                ? state.searchText.isEmpty
                      ? const SizedBox()
                      : Empty(
                          isImage: false,
                          icon: Icons.search_outlined,
                          title:
                              "${S.of(context).noTitleWithName}: ${state.searchText}",
                          description: S.of(context).reviewIndexOfBook,
                        )
                : HomeTitlesListView(titles: state.searchedTitles);
          },
        );
      },
    );
  }
}
