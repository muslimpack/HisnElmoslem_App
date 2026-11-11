import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
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
                  if (state.allCounters.length > 1)
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

/// Previous and next counter, and "2 of 5" that opens a list to jump to any counter.
class TallyCounterHeader extends StatelessWidget {
  final DbTally counter;
  final int total;

  const TallyCounterHeader({super.key, required this.counter, required this.total});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final index = context.select<TallyBloc, int>((bloc) {
      final state = bloc.state;
      return state is TallyLoadedState
          ? state.allCounters.indexWhere((c) => c.id == counter.id) + 1
          : 0;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: s.previous,
            iconSize: 24,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () => TallyActions.previous(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Center(
              child: TextButton.icon(
                onPressed: () => TallyCounterPickerSheet.show(context),
                icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                label: Text(s.tallyCountOf(index, total).toArabicNumber()),
              ),
            ),
          ),
          IconButton(
            tooltip: s.next,
            iconSize: 24,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () => TallyActions.next(context),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

/// The counter's text above the ring. Tap anywhere in here to count: one tap, one
/// count. It is a real button for screen readers, which hear the text, the count and
/// the size of the cycle.
class TallyCountArea extends StatelessWidget {
  final DbTally counter;

  const TallyCountArea({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Semantics(
        button: true,
        liveRegion: true,
        excludeSemantics: true,
        label: s.tallyCountSemantics(counter.title, counter.count, counter.cycleSize),
        onTapHint: s.tallyAddOne,
        onTap: () => TallyActions.count(context),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => TallyActions.count(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // The ring takes what it needs; the text gets the rest, so a long
                // text is shown in full (and scrolls when even the smallest size
                // does not fit).
                final ring = (constraints.maxHeight * 0.36)
                    .clamp(150.0, 250.0)
                    .clamp(0.0, constraints.maxWidth - 32);

                return Column(
                  children: [
                    Expanded(child: TallyTextCard(text: counter.title)),
                    SizedBox(
                      height: ring,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TallyCounterRing(counter: counter),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The text of the counter, as large as fits. When even the smallest size does not fit
/// it scrolls, with a scrollbar showing that there is more.
class TallyTextCard extends StatefulWidget {
  final String text;

  const TallyTextCard({super.key, required this.text});

  static const double minFontSize = 18;

  @override
  State<TallyTextCard> createState() => _TallyTextCardState();
}

class _TallyTextCardState extends State<TallyTextCard> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.select<SettingsCubit, double>((cubit) => cubit.state.fontSize);
    final maxFont = (fontSize * 10).clamp(22.0, 38.0);

    TextStyle style(double size) => TextStyle(
      fontSize: size,
      height: 1.9,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withAlpha(235),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Center(
          child: AutoSizeText(
            widget.text,
            textAlign: TextAlign.center,
            minFontSize: TallyTextCard.minFontSize,
            maxFontSize: maxFont,
            style: style(maxFont),
            overflowReplacement: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.start,
                    style: style(TallyTextCard.minFontSize + 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
