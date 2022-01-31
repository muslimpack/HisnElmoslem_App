import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/tally_controller.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Tally extends StatelessWidget {
  Tally({Key? key}) : super(key: key);

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
          title: Text("السبحة"),
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
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .8,
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '${controller.counter}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    SizedBox(
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
                                '${controller.circvaltimes}  عدد المرات',
                            bottomLabelStyle: TextStyle(
                              fontSize: 25,
                            ),
                            mainLabelStyle:
                                TextStyle(fontSize: 70, color: Colors.white),
                            modifier: (double value) {
                              final circval = value.ceil().toInt().toString();
                              return '$circval';
                            },
                          ),
                          customWidths: CustomSliderWidths(
                              progressBarWidth: 40, trackWidth: 40),
                          customColors: CustomSliderColors(
                            trackColor: Colors.blue.shade100,
                            // shadowColor: Colors.orange,
                            progressBarColors: [
                              Colors.blue[200]!,
                              Colors.blue[400]!,
                              //  Colors.orange
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
          child: Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        controller.resetCounter();
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.remove),
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
