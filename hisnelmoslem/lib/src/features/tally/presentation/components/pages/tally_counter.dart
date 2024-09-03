import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
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
                      child: SleekCircularSlider(
                        initialValue: activeCounter.count.toDouble() %
                            activeCounter.countReset,
                        max: activeCounter.countReset.toDouble(),
                        appearance: CircularSliderAppearance(
                          angleRange: 360,
                          startAngle: 270,
                          infoProperties: InfoProperties(
                            bottomLabelText:
                                '${"times".tr}: ${activeCounter.count ~/ activeCounter.countReset}'
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
          bottomNavigationBar: const TallyBotttomBar(),
        );
      },
    );
  }
}

class TallyBotttomBar extends StatelessWidget {
  const TallyBotttomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_right),
              onPressed: () {
                context.read<TallyBloc>().add(TallyPreviousCounterEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (_) {
                    return YesOrNoDialog(
                      msg:
                          "your progress will be deleted and you can't undo that"
                              .tr,
                      onYes: () async {
                        context
                            .read<TallyBloc>()
                            .add(TallyResetActiveCounterEvent());
                      },
                    );
                  },
                );
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
    );
  }
}
