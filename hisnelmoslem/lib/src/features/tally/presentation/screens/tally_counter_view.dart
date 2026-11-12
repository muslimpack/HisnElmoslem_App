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
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';

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

/// The counter's text, as large as the room allows, and under it the total. Tap anywhere
/// in here to count; the button in the dock counts too. It is a real button for screen
/// readers, which hear the text, the count and the size of the cycle.
class TallyCountArea extends StatelessWidget {
  final DbTally counter;

  const TallyCountArea({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Semantics(
        button: true,
        excludeSemantics: true,
        // Read once when focused. The count is announced by the dock counter.
        label: counter.title,
        onTapHint: s.tallyAddOne,
        onTap: () => TallyActions.count(context),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => TallyActions.count(context),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      child: TallyZikrText(key: ValueKey(counter.id), text: counter.title),
                    ),
                  ),
                ),
                TallyTotalLine(counter: counter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Total: 46 · Cycles: 1", and what the voice has counted while a session plays.
class TallyTotalLine extends StatelessWidget {
  final DbTally counter;

  const TallyTotalLine({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final sessionCount = context.select<TallyAudioCubit, int?>(
      (audio) => audio.state.isActive ? audio.state.sessionCount : null,
    );

    final parts = <String>[
      s.tallyTotal(counter.count),
      if (counter.cycles > 0) s.tallyCyclesDone(counter.cycles),
      if (sessionCount != null) s.tallySessionCounted(sessionCount),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        parts.join('  ·  ').toArabicNumber(),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

/// The text of the counter with no frame: the largest size that fits, centred. When even
/// the smallest size does not fit it scrolls, with a scrollbar showing there is more.
class TallyZikrText extends StatefulWidget {
  final String text;

  const TallyZikrText({super.key, required this.text});

  static const double minFontSize = 18;

  @override
  State<TallyZikrText> createState() => _TallyZikrTextState();
}

class _TallyZikrTextState extends State<TallyZikrText> {
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
    // A whole number: the auto size steps by whole sizes.
    final maxFont = (fontSize * 30).roundToDouble().clamp(48.0, 96.0);

    TextStyle style(double size) => TextStyle(
      fontSize: size,
      height: 1.8,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    return Center(
      child: AutoSizeText(
        widget.text,
        textAlign: TextAlign.center,
        minFontSize: TallyZikrText.minFontSize,
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
                style: style(TallyZikrText.minFontSize + 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
