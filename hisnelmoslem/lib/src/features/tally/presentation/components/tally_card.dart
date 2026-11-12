import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_datetime.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';

/// One counter in the list: its whole text, the count and the progress of the cycle.
class TallyCard extends StatelessWidget {
  final DbTally dbTally;

  const TallyCard({super.key, required this.dbTally});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final s = S.of(context);
    final isActivated = dbTally.isActivated;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Semantics(
        button: true,
        selected: isActivated,
        child: Material(
          color: isActivated ? primary.withAlpha(24) : colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isActivated ? primary.withAlpha(140) : Colors.transparent,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isActivated ? () {} : () => TallyActions.select(context, dbTally),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            dbTally.title,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              height: 1.7,
                              fontWeight: isActivated ? FontWeight.bold : FontWeight.w500,
                              color: isActivated ? primary : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${dbTally.count}'.toArabicNumber(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isActivated ? primary : colorScheme.onSurface,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              s
                                  .tallyCountOf(dbTally.shownInCycle, dbTally.cycleSize)
                                  .toArabicNumber(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    // The percentage would be read before the text of the card.
                    child: ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: dbTally.cycleProgress,
                          backgroundColor: primary.withAlpha(30),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (dbTally.hasAudio) ...[
                        Icon(
                          Icons.mic_rounded,
                          size: 18,
                          semanticLabel: s.recordMyVoiceBadge,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (dbTally.cycles > 0) ...[
                        Icon(Icons.loop_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(
                          s.tallyCyclesDone(dbTally.cycles).toArabicNumber(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          dbTally.lastUpdate.humanize,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(125),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: s.edit,
                        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                        style: IconButton.styleFrom(
                          foregroundColor: colorScheme.onSurface.withAlpha(150),
                        ),
                        onPressed: () => TallyActions.edit(context, dbTally),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
