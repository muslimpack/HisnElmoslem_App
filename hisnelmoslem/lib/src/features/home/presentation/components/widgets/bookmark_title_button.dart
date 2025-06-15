import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';

class BookmarkTitleButton extends StatelessWidget {
  final int titleId;
  const BookmarkTitleButton({super.key, required this.titleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: context.read<HomeBloc>(),
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }
        final isBookmarked = state.bookmarkedTitlesIds.contains(titleId);

        if (isBookmarked) {
          return IconButton(
            onPressed: () {
              sl<HomeBloc>().add(
                HomeToggleTitleBookmarkEvent(titleId: titleId, bookmark: false),
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
              sl<HomeBloc>().add(
                HomeToggleTitleBookmarkEvent(titleId: titleId, bookmark: true),
              );
            },
            icon: const Icon(Icons.bookmark_add_outlined),
          );
        }
      },
    );
  }
}
