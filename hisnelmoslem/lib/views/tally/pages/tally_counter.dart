import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/tally_controller.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class TallyCounterView extends StatelessWidget {
  const TallyCounterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * .75;
    double height = MediaQuery.of(context).size.height * .75;
    late double smalLenght;
    if (width > height) {
      smalLenght = height;
    } else {
      smalLenght = width;
    }
    return GetBuilder<TallyController>(builder: (controller) {
      return controller.isLoading
          ? const Loading()
          : controller.currentDBTally == null
              ? const Empty(
                  isImage: false,
                  icon: Icons.watch_rounded,
                  title: "لا يوجد عداد نشط",
                  description:
                      "لتفعيل العداد اذهب إلى عرض التسبيحات واضغط على علامة العداد",
                )
              : Scaffold(
                  body: InkWell(
                    onTap: () {
                      // controller.incrementCounter();
                      controller.increaseDBCounter();
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
                              controller.currentDBTally!.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: "uthmanic",
                              ),
                            ),
                          ),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .8,
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                '${controller.currentDBTally!.count}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SleekCircularSlider(
                            initialValue: controller.circval,
                            max: controller.circleResetEvery.toDouble(),
                            appearance: CircularSliderAppearance(
                                angleRange: 360,
                                startAngle: 270,
                                infoProperties: InfoProperties(
                                  bottomLabelText:
                                      'عدد المرات ${controller.circvaltimes}',
                                  bottomLabelStyle: const TextStyle(
                                    fontSize: 25,
                                  ),
                                  mainLabelStyle: const TextStyle(fontSize: 70),
                                  modifier: (double value) {
                                    final circval =
                                        value.ceil().toInt().toString();
                                    return circval;
                                  },
                                ),
                                customWidths: CustomSliderWidths(
                                    progressBarWidth: 40, trackWidth: 40),
                                customColors: CustomSliderColors(
                                  // trackColor: grey,
                                  // hideShadow: true,
                                  trackColor: transparent,
                                  progressBarColors: [
                                    mainColor,
                                    mainColor,
                                    //  orange
                                  ],
                                ),
                                size: smalLenght),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    //elevation: 20,
                    color: Theme.of(context).primaryColor,
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  // controller.resetCounter();
                                  controller.resetDBCounter();
                                }),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (controller.counter == 0) {
                                  } else {
                                    // controller.minusCounter();
                                    controller.decreaseDBCounter();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
    });
  }
}
