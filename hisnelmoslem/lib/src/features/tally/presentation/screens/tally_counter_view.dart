import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_counter_picker_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_counter_ring.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class TallyCounterView extends StatelessWidget {
  const TallyCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallyBloc, TallyState>(
      builder: (context, state) {
        if (state is! TallyLoadedState) return const Loading();

        final activeCounter = state.activeCounter;

        if (activeCounter == null) {
          final isCountersEmpty = state.allCounters.isEmpty;
          return Empty(
            isImage: false,
            icon: Icons.watch_rounded,
            title: S.of(context).noActiveCounter,
            description: S.of(context).activateCounterInstructions,
            buttonText: isCountersEmpty ? S.of(context).addNewCounter : "",
            onButtonCLick: !isCountersEmpty ? null : () => TallyActions.add(context),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/grid.png"),
                repeat: ImageRepeat.repeat,
                opacity: .03,
                colorFilter: ColorFilter.mode(
                  theme.scaffoldBackgroundColor.getContrastColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TallyCounterHeader(counter: activeCounter, total: state.allCounters.length),
                  Expanded(child: TallyCountArea(counter: activeCounter)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The counter's name between previous and next, with its place in the list. Tapping
/// the name opens a list to jump to another counter.
class TallyCounterHeader extends StatelessWidget {
  final DbTally counter;
  final int total;

  const TallyCounterHeader({super.key, required this.counter, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final many = total > 1;
    final index = context.select<TallyBloc, int>((bloc) {
      final state = bloc.state;
      return state is TallyLoadedState
          ? state.allCounters.indexWhere((c) => c.id == counter.id) + 1
          : 0;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: s.previous,
            iconSize: 28,
            constraints: const BoxConstraints.tightFor(width: 52, height: 52),
            onPressed: many ? () => TallyActions.previous(context) : null,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: '${counter.title}. ${s.tallyPickCounter}',
              excludeSemantics: true,
              onTap: () => TallyCounterPickerSheet.show(context),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => TallyCounterPickerSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        counter.title,
                        maxLines: 2,
                        minFontSize: 16,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.4,
                        ),
                      ),
                      if (many)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$index / $total'.toArabicNumber(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: s.next,
            iconSize: 28,
            constraints: const BoxConstraints.tightFor(width: 52, height: 52),
            onPressed: many ? () => TallyActions.next(context) : null,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

/// The big tap target: one tap, one count. It is a real button for screen readers,
/// which hear the name, the count and the size of the cycle.
class TallyCountArea extends StatelessWidget {
  final DbTally counter;

  const TallyCountArea({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Semantics(
        button: true,
        liveRegion: true,
        excludeSemantics: true,
        label: s.tallyCountSemantics(counter.title, counter.count, counter.cycleSize),
        onTapHint: s.tallyAddOne,
        onTap: () => TallyActions.count(context),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => TallyActions.count(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TallyCounterRing(counter: counter),
            ),
          ),
        ),
      ),
    );
  }
}
