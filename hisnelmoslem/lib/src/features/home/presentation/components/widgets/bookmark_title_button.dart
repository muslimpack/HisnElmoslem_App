import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';

class BookmarkTitleButton extends StatelessWidget {
  final int titleId;
  const BookmarkTitleButton({super.key, required this.titleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: context.read<BookmarkBloc>(),
      builder: (context, state) {
        if (state is! BookmarkLoadedState) {
          return const SizedBox();
        }
        final isBookmarked = state.bookmarkedTitlesIds.contains(titleId);

        if (isBookmarked) {
          return IconButton(
            onPressed: () {
              sl<BookmarkBloc>().add(
                BookmarkToggleTitleBookmarkEvent(
                  titleId: titleId,
                  bookmark: false,
                ),
              );
            },
            icon: Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          return IconButton(
            onPressed: () {
              sl<BookmarkBloc>().add(
                BookmarkToggleTitleBookmarkEvent(
                  titleId: titleId,
                  bookmark: true,
                ),
              );
            },
            icon: const Icon(Icons.bookmark_add_outlined),
          );
        }
      },
    );
  }
}
