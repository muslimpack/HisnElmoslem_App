import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/zikr_preview_text.dart';

/// A user-authored zikr in lists (favourites, search). Tap to read it in full.
class CustomZikrCard extends StatelessWidget {
  final CustomZikr zikr;

  const CustomZikrCard({super.key, required this.zikr});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => CustomZikrDialog(zikr: zikr),
        ),
        title: ZikrPreviewText(content: zikr.content, maxLines: 4),
        subtitle: zikr.source.isEmpty
            ? null
            : Text(zikr.source, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: CustomZikrFavouriteToggle(zikrId: zikr.id),
      ),
    );
  }
}

/// Heart toggle for a custom zikr, driven by [CustomTitlesBloc].
class CustomZikrFavouriteToggle extends StatelessWidget {
  final int zikrId;
  const CustomZikrFavouriteToggle({super.key, required this.zikrId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
      builder: (context, state) {
        if (state is! CustomTitlesLoadedState) return const SizedBox.shrink();
        final isFavourite = state.favouriteZikrs.any((z) => z.id == zikrId);

        return IconButton(
          tooltip: S.of(context).bookmark,
          padding: EdgeInsets.zero,
          icon: isFavourite
              ? Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.favorite_border),
          onPressed: () => context.read<CustomTitlesBloc>().add(
            CustomZikrToggleFavouriteEvent(zikrId: zikrId, favourite: !isFavourite),
          ),
        );
      },
    );
  }
}

/// Full text of a custom zikr with its source and virtue.
class CustomZikrDialog extends StatelessWidget {
  final CustomZikr zikr;
  const CustomZikrDialog({super.key, required this.zikr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(
            zikr.content,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontFamily: "Kitab", height: 2),
          ),
          if (zikr.fadl.isNotEmpty) ...[
            const Divider(height: 24),
            Text("${S.of(context).zikrFadl}: ${zikr.fadl}"),
          ],
          if (zikr.source.isNotEmpty) ...[
            const Divider(height: 24),
            Text(zikr.source, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).close)),
      ],
    );
  }
}
