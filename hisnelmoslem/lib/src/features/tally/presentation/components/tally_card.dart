import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_datetime.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_editor.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class TallyCard extends StatelessWidget {
  final DbTally dbTally;

  const TallyCard({super.key, required this.dbTally});

  @override
  Widget build(BuildContext context) {
    final state = context.read<TallyBloc>().state;
    final bool isActivated;
    if (state is TallyLoadedState) {
      isActivated = dbTally.id == state.activeCounter?.id;
    } else {
      isActivated = false;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        elevation: isActivated ? 3 : 1,
        borderRadius: BorderRadius.circular(16),
        color: isActivated
            ? Theme.of(context).brightness == Brightness.light
                  ? null
                  : primary.withAlpha((.05 * 255).round())
            : colorScheme.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<TallyBloc>().add(
              TallyToggleCounterActivationEvent(
                counter: dbTally,
                activate: !isActivated,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isActivated
                  ? Border.all(
                      color: primary.withAlpha((.4 * 255).round()),
                      width: 1.5,
                    )
                  : null,
              image: isActivated
                  ? DecorationImage(
                      image: const AssetImage("assets/images/grid.png"),
                      fit: BoxFit.fitWidth,
                      repeat: ImageRepeat.repeat,
                      opacity: .06,
                      colorFilter: ColorFilter.mode(
                        theme.scaffoldBackgroundColor.getContrastColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : null,
            ),
            child: Row(
              spacing: 8,
              children: [
                // Active indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 4,
                  height: 40,
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  decoration: BoxDecoration(
                    color: isActivated ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Title + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dbTally.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isActivated ? FontWeight.bold : FontWeight.normal,
                          color: isActivated ? primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dbTally.lastUpdate.humanize,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(125),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  spacing: 4,
                  children: [
                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActivated
                            ? primary.withAlpha((.2 * 255).round())
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dbTally.count
                            .toString()
                            .padLeft(
                              (state as TallyLoadedState).maxCounterNumberLength,
                              "0",
                            )
                            .toArabicNumber(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActivated ? primary : colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    // Edit button
                    IconButton(
                      tooltip: S.of(context).edit,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.onSurface.withAlpha(130),
                      ),
                      onPressed: () async {
                        final EditorResult<DbTally>? result = await showTallyEditorDialog(
                          context: context,
                          dbTally: dbTally,
                        );

                        if (result == null || !context.mounted) return;
                        switch (result.action) {
                          case EditorActionEnum.edit:
                            context.read<TallyBloc>().add(
                              TallyEditCounterEvent(counter: result.value),
                            );
                          case EditorActionEnum.delete:
                            final bool? confirm = await showDialog(
                              context: context,
                              builder: (_) => YesOrNoDialog(
                                msg: S.of(context).counterWillBeDeleted,
                              ),
                            );
                            if (confirm == null || !confirm || !context.mounted) return;
                            context.read<TallyBloc>().add(
                              TallyDeleteCounterEvent(counter: dbTally),
                            );
                          default:
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
