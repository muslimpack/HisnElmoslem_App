import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/gradient_widget.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_editor.dart';
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
            onButtonCLick: !isCountersEmpty
                ? null
                : () async {
                    final EditorResult<DbTally>? result = await showTallyEditorDialog(
                      context: context,
                    );
                    if (result == null || !context.mounted) return;
                    context.read<TallyBloc>().add(
                      TallyAddCounterEvent(counter: result.value),
                    );
                  },
          );
        }

        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;
        final double resetEvery = state.resetEvery;
        final int cycles = activeCounter.count ~/ resetEvery;
        final double progress = (activeCounter.count - cycles * resetEvery) / resetEvery;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () => context.read<TallyBloc>().add(
              TallyIncreaseActiveCounterEvent(),
            ),
            child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Title area ──────────────────────────────────────
                      Expanded(
                        flex: 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Loading spinner top-right
                            if (state.iterationMode != TallyIterationMode.none)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    value: state.loadingIteration ? null : 1,
                                    color: primary,
                                  ),
                                ),
                              ),
                            // Counter title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: AutoSizeText(
                                activeCounter.title,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Main count ──────────────────────────────────────
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: GradientWidget(
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${activeCounter.count}'.toArabicNumber(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primary.withAlpha((.4 * 255).round()),
                                primary,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Cycles row ──────────────────────────────────────
                      if (cycles > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              GradientWidget(
                                const Icon(Icons.loop_rounded, size: 28),
                                gradient: LinearGradient(
                                  colors: [
                                    primary.withAlpha((.5 * 255).round()),
                                    primary,
                                  ],
                                ),
                              ),
                              GradientWidget(
                                Text(
                                  '$cycles'.toArabicNumber(),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    primary.withAlpha((.5 * 255).round()),
                                    primary,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Progress bar ────────────────────────────────────
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        builder: (context, value, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Percentage label
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${(value * 100).toInt()}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: primary.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  minHeight: 14,
                                  value: value,
                                  backgroundColor: primary.withAlpha(
                                    (.15 * 255).round(),
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
