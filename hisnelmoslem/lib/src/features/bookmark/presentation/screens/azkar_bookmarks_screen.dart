import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/components/home_bookmarked_content_card.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_zikr_card.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class AzkarBookmarksScreen extends StatelessWidget {
  const AzkarBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }

        return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
          builder: (context, customState) {
            final List<CustomZikr> customZikrs = customState is CustomTitlesLoadedState
                ? customState.favouriteZikrs
                : const [];

            return state.bookmarkedContents.isEmpty && customZikrs.isEmpty
                ? Empty(
                    isImage: false,
                    icon: Icons.favorite_outline_rounded,
                    title: S.of(context).nothingFoundInFavorites,
                    description: S.of(context).noZikrSelectedAsFavorite,
                  )
                : Scaffold(
                    body: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 50),
                      itemCount: state.bookmarkedContents.length + customZikrs.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= state.bookmarkedContents.length) {
                          final zikr = customZikrs[index - state.bookmarkedContents.length];
                          return CustomZikrCard(key: ValueKey("custom_${zikr.id}"), zikr: zikr);
                        }
                        final DbContent dbContent = state.bookmarkedContents[index];
                        final DbTitle dbTitle = state.titles
                            .where((element) => element.id == dbContent.titleId)
                            .first;

                        return HomeBookmarkedContentCard(
                          dbContent: dbContent,
                          dbTitle: dbTitle,
                        );
                      },
                    ),
                    bottomNavigationBar: const BottomAppBar(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[Expanded(child: FontSettingsBar())],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}
