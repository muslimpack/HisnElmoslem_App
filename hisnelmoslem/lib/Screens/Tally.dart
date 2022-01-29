import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Tally extends StatefulWidget {
  Tally({Key? key}) : super(key: key);

  @override
  _TallyState createState() => _TallyState();
}

class _TallyState extends State<Tally> {
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  @override
  void initState() {
    getData();
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          minusCounter();
        }
        if (call.arguments == "VOLUME_UP_UP") {
          incrementCounter();
        }
      }

      return Future.value(null);
    });

    super.initState();
  }

  @override
  void dispose() {
    // volumeButton?.cancel();
    super.dispose();
  }

  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  int counter = 0;
  double circval = 0;
  int? circvaltimes = 0;

  Future getData() async {
    final SharedPreferences prefs = await _sprefs;
    if (prefs.getString('counter') == null) {
      prefs.setString('counter', "0");
    }
    int data = int.parse((prefs.getString('counter')!));
    this.setState(() {
      counter = data;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
    });
  }

  Future incrementCounter() async {
    final SharedPreferences prefs = await _sprefs;
    HapticFeedback.vibrate();
    setState(() {
      counter++;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

  Future resetCounter() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      counter = 0;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

  Future minusCounter() async {
    final SharedPreferences prefs = await _sprefs;
    HapticFeedback.heavyImpact();
    setState(() {
      counter--;
      if (counter < 0) {
        counter = 0;
      }
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

//

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * .75;
    double height = MediaQuery.of(context).size.height * .75;
    late double smalLenght;
    if (width > height) {
      setState(() {
        smalLenght = height;
      });
    } else {
      smalLenght = width;
    }
    return Scaffold(
      appBar: AppBar(
        //elevation: 0,
        title: Text("السبحة"), centerTitle: true,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: InkWell(
        onTap: () {
          incrementCounter();
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
                        '$counter',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SleekCircularSlider(
                    initialValue: circval,
                    max: 33,
                    appearance: CircularSliderAppearance(
                        angleRange: 360,
                        startAngle: 270,
                        infoProperties: InfoProperties(
                          bottomLabelText: '$circvaltimes  عدد المرات',
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
                      resetCounter();
                    }),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (counter == 0) {
                      } else {
                        minusCounter();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
