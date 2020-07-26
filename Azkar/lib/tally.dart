import 'dart:async';
import 'package:Azkar/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Tally extends StatefulWidget {
  Tally({Key key}) : super(key: key);

  @override
  _TallyState createState() => _TallyState();
}

class _TallyState extends State<Tally> {
  //final ValueNotifier<int> _counter = ValueNotifier<int>(0);

//a

  @override
  void initState() {
    super.initState();
    getData();
  }

  //
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  int counter = 0;
  double circval;
  int circvaltimes;
  @override
  Future<String> getData() async {
    final SharedPreferences prefs = await _sprefs;
    if (prefs.getString('counter') == null) {
      prefs.setString('counter', "0");
    }
    int data = int.parse((prefs.getString('counter')));
    this.setState(() {
      counter = data;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
    });
  }

  Future<String> incrementCounter() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      counter++;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

  Future<String> resetCounter() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      counter = 0;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

  Future<String> minusCounter() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      counter--;
      circval = counter.toDouble() - (counter ~/ 33) * 33;
      circvaltimes = counter ~/ 33;
      prefs.setString('counter', counter.toString());
    });
  }

//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          "السُبحة",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: InkWell(
        onTap: () {
          incrementCounter();

          HapticFeedback.vibrate();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    elevation: 10,
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
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
                          progressBarWidth: 40,
                        ),
                        customColors: CustomSliderColors(
                          trackColor: Colors.orange,
                          shadowColor: Colors.orange,
                          progressBarColors: [
                            Colors.orange[200],
                            Colors.orange[400],
                            Colors.orange
                          ],
                        ),
                        size: MediaQuery.of(context).size.width * .75),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 20,
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
              Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                    }),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(Theme.of(context).brightness == Brightness.dark
                        ? Icons.wb_sunny
                        : Icons.cloud),
                    onPressed: () {
                      DynamicTheme.of(context).setBrightness(
                          Theme.of(context).brightness == Brightness.dark
                              ? Brightness.light
                              : Brightness.dark);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
