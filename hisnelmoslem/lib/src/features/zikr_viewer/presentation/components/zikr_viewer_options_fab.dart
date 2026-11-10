import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/animated_zikr_count.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_actions_sheet.dart';

/// Labelled button that opens the actions of the current zikr. It also shows the
/// remaining count, so the user sees both the progress and where the menu is.
class ZikrViewerOptionsFab extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerOptionsFab({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      heroTag: 'zikr_options',
      tooltip: S.of(context).zikrOptions,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      onPressed: () => ZikrActionsSheet.show(context, dbContent: dbContent),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimaryContainer.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedZikrCounter(
              count: dbContent.count,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(S.of(context).zikrOptions),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_up_rounded),
        ],
      ),
    );
  }
}
