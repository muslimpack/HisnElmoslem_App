import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_counter_view_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
          return Empty(
            isImage: false,
            icon: Icons.watch_rounded,
            title: S.of(context).noActiveCounter,
            description: S.of(context).activateCounterInstructions,
          );
        }

        final double resetEvery = state.resetEvery;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              context.read<TallyBloc>().add(TallyIncreaseActiveCounterEvent());
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    child: Container(
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
                                fontSize: 30,
                                fontFamily: "uthmanic",
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Stack(
                        fit: StackFit.expand,
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
                          SleekCircularSlider(
                            initialValue:
                                activeCounter.count.toDouble() % resetEvery,
                            max: resetEvery,
                            appearance: CircularSliderAppearance(
                              angleRange: 360,
                              startAngle: 270,
                              infoProperties: InfoProperties(
                                bottomLabelText:
                                    '${S.of(context).times}: ${activeCounter.count ~/ resetEvery}'
                                        .toArabicNumber(),
                                bottomLabelStyle: const TextStyle(
                                  fontSize: 25,
                                ),
                                mainLabelStyle: const TextStyle(fontSize: 70),
                                modifier: (double value) {
                                  final circValue =
                                      value.round().toString().toArabicNumber();
                                  return circValue;
                                },
                              ),
                              customWidths: CustomSliderWidths(
                                progressBarWidth: 30,
                                trackWidth: 30,
                              ),
                              customColors: CustomSliderColors(
                                dotColor: Colors.transparent,
                                hideShadow: true,
                                trackColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(.1),
                                progressBarColors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.7),
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.all(20),
                      child: FittedBox(
                        child: Text(
                          '${activeCounter.count}'.toArabicNumber(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TallyCounterViewBottomBar(),
        );
      },
    );
  }
}
