import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_card.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/title_card.dart';
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

        return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
          builder: (context, customState) {
            final List<CustomTitle> customTitles = customState is CustomTitlesLoadedState
                ? customState.favouriteTitles
                : const [];
            final originals = state.bookmarkedTitles;

            if (originals.isEmpty && customTitles.isEmpty) {
              return Empty(
                isImage: false,
                icon: Icons.bookmark_outline_rounded,
                title: S.of(context).nothingFoundInFavorites,
                description: S.of(context).noTitleMarkedAsFavorite,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: originals.length + customTitles.length,
              itemBuilder: (context, index) {
                if (index < originals.length) {
                  return TitleCard(dbTitle: originals[index]);
                }
                final title = customTitles[index - originals.length];
                return CustomTitleCard(key: ValueKey("custom_${title.id}"), title: title);
              },
            );
          },
        );
      },
    );
  }
}
