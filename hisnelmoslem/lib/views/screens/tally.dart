import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/tally_controller.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Tally extends StatelessWidget {
  const Tally({Key? key}) : super(key: key);

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
    // if (width > height) {
    //   setState(() {
    //     smalLenght = height;
    //   });
    // } else {
    //   smalLenght = width;
    // }
    return GetBuilder<TallyController>(
      init: TallyController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text("السبحة"),
          centerTitle: true,
        ),
        body: InkWell(
          onTap: () {
            controller.incrementCounter();
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .8,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '${controller.counter}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SleekCircularSlider(
                      initialValue: controller.circval,
                      max: 33,
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
                              final circval = value.ceil().toInt().toString();
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
                  ],
                )
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
                        controller.resetCounter();
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (controller.counter == 0) {
                        } else {
                          controller.minusCounter();
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
