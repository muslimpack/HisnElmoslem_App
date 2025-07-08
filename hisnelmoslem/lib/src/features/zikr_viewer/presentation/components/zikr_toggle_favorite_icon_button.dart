import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrToggleFavoriteIconButton extends StatelessWidget {
  final DbContent dbContent;
  const ZikrToggleFavoriteIconButton({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      bloc: context.read<BookmarkBloc>(),
      builder: (context, state) {
        if (state is! BookmarkLoadedState) {
          return const SizedBox.shrink();
        }
        final isBookmarked = state.bookmarkedContents.any(
          (content) => content.id == dbContent.id,
        );

        if (!isBookmarked) {
          return IconButton(
            tooltip: S.of(context).bookmark,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              context.read<BookmarkBloc>().add(
                BookmarkToggleContentBookmarkEvent(
                  content: dbContent,
                  bookmark: true,
                ),
              );
            },
          );
        }

        return IconButton(
          tooltip: S.of(context).bookmark,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            context.read<BookmarkBloc>().add(
              BookmarkToggleContentBookmarkEvent(
                content: dbContent,
                bookmark: false,
              ),
            );
          },
        );
      },
    );
  }
}
