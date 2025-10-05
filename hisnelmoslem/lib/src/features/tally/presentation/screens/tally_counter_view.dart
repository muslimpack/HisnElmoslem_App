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
        if (state is! TallyLoadedState) {
          return const Loading();
        }

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

                    context.read<TallyBloc>().add(TallyAddCounterEvent(counter: result.value));
                  },
          );
        }

        final double resetEvery = state.resetEvery;
        final int cycles = activeCounter.count ~/ resetEvery;

        return Scaffold(
          resizeToAvoidBottomInset: false,

          body: GestureDetector(
            onTap: () {
              context.read<TallyBloc>().add(TallyIncreaseActiveCounterEvent());
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/images/grid.png"),
                  repeat: ImageRepeat.repeat,
                  opacity: .03,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).scaffoldBackgroundColor.getContrastColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: [
                      if (state.iterationMode != TallyIterationMode.none)
                        Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              value: state.loadingIteration ? null : 1,
                            ),
                          ),
                        ),
                      Container(
                        height: 150,
                        constraints: const BoxConstraints(minHeight: 150),
                        child: Center(
                          child: ListView(
                            padding: const EdgeInsets.all(20),
                            shrinkWrap: true,
                            children: [
                              Text(
                                activeCounter.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: "uthmanic",
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: GradientWidget(
                      FittedBox(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            // Combined fade + scale animation
                            return ScaleTransition(
                              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: Text(
                            key: ValueKey<int>(activeCounter.count),
                            '${activeCounter.count}'.toArabicNumber(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha((.3 * 255).round()),
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ),
                  ),

                  GradientWidget(
                    Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.circle_outlined, size: 45),
                        if (cycles > 0)
                          Text(
                            '$cycles'.toArabicNumber(),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                      ],
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withAlpha((.5 * 255).round()),
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),

                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: (activeCounter.count - cycles * resetEvery) / resetEvery,
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        minHeight: 20,
                        borderRadius: BorderRadius.circular(10),
                        value: value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
