import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';

/// Bookmark toggle for a custom title (same look as the original title bookmark button).
class CustomTitleFavouriteButton extends StatelessWidget {
  final int titleId;
  final bool isFavourite;

  const CustomTitleFavouriteButton({
    super.key,
    required this.titleId,
    required this.isFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<CustomTitlesBloc>().add(
          CustomTitlesToggleFavouriteEvent(titleId: titleId, favourite: !isFavourite),
        );
      },
      icon: isFavourite
          ? Icon(Icons.bookmark, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.bookmark_add_outlined),
    );
  }
}
