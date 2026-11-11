import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_favourite_button.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_zikr_card.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Title bookmark shown in the viewer app bar for a custom title.
class ViewerCustomTitleFavouriteButton extends StatelessWidget {
  final int customTitleId;
  const ViewerCustomTitleFavouriteButton({super.key, required this.customTitleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
      builder: (context, state) {
        if (state is! CustomTitlesLoadedState) return const SizedBox.shrink();
        final isFavourite = state.titles.any((t) => t.id == customTitleId && t.isFavourite);
        return CustomTitleFavouriteButton(titleId: customTitleId, isFavourite: isFavourite);
      },
    );
  }
}

/// Heart shown in the viewer for zikrs the user authored; nothing for other items.
class ViewerCustomZikrFavouriteButton extends StatelessWidget {
  final DbContent dbContent;
  const ViewerCustomZikrFavouriteButton({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    final zikrId = dbContent.customZikrId;
    if (zikrId == null) return const SizedBox.shrink();
    return CustomZikrFavouriteToggle(zikrId: zikrId);
  }
}
