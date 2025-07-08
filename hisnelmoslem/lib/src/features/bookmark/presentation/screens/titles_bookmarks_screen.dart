import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_list_view.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';

class TitlesBookmarksScreen extends StatelessWidget {
  const TitlesBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }
        return state.bookmarkedTitles.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.bookmark_outline_rounded,
                title: S.of(context).nothingFoundInFavorites,
                description: S.of(context).noTitleMarkedAsFavorite,
              )
            : HomeTitlesListView(titles: state.bookmarkedTitles);
      },
    );
  }
}
