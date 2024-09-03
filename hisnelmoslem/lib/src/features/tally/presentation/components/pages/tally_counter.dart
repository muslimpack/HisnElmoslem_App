import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class TallyCounterView extends StatelessWidget {
  const TallyCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * .75;
    final double height = MediaQuery.of(context).size.height * .75;
    late double smallLength;
    if (width > height) {
      smallLength = height;
    } else {
      smallLength = width;
    }
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
            title: "no active counter".tr,
            description:
                "to activate counter go to counters then click to counter icon beside the counter you want"
                    .tr,
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              context.read<TallyBloc>().add(TallyIncreaseActiveCounterEvent());
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      activeCounter.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: "uthmanic",
                      ),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .8,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '${activeCounter.count}'.toArabicNumber(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SleekCircularSlider(
                    initialValue: activeCounter.count.toDouble() %
                        activeCounter.countReset,
                    max: activeCounter.countReset.toDouble(),
                    appearance: CircularSliderAppearance(
                      angleRange: 360,
                      startAngle: 270,
                      infoProperties: InfoProperties(
                        bottomLabelText:
                            '${"times".tr} | ${activeCounter.count ~/ activeCounter.countReset}'
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
                        progressBarWidth: 20,
                        trackWidth: 20,
                      ),
                      customColors: CustomSliderColors(
                        // trackColor: grey,
                        hideShadow: true,
                        trackColor: Colors.transparent,
                        progressBarColors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary,
                          //  orange
                        ],
                      ),
                      size: smallLength,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_right),
                    onPressed: () {
                      context
                          .read<TallyBloc>()
                          .add(TallyPreviousCounterEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context
                          .read<TallyBloc>()
                          .add(TallyResetActiveCounterEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      context
                          .read<TallyBloc>()
                          .add(TallyDecreaseActiveCounterEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_left),
                    onPressed: () {
                      context.read<TallyBloc>().add(TallyNextCounterEvent());
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
