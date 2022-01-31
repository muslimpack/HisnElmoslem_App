import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TallyController extends GetxController {
  /* *************** Variables *************** */
  //
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  //
  int counter = 0;
  double circval = 0;
  int? circvaltimes = 0;
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
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
  }

  /* *************** Functions *************** */
  //

  Future getData() async {
    final SharedPreferences prefs = await _sprefs;
    if (prefs.getString('counter') == null) {
      prefs.setString('counter', "0");
    }
    int data = int.parse((prefs.getString('counter')!));
    //
    counter = data;
    circval = counter.toDouble() - (counter ~/ 33) * 33;
    circvaltimes = counter ~/ 33;
    //
    update();
  }

  Future incrementCounter() async {
    final SharedPreferences prefs = await _sprefs;
    HapticFeedback.vibrate();
    //
    counter++;
    circval = counter.toDouble() - (counter ~/ 33) * 33;
    circvaltimes = counter ~/ 33;
    prefs.setString('counter', counter.toString());
    //
    update();
  }

  Future resetCounter() async {
    final SharedPreferences prefs = await _sprefs;
    //
    counter = 0;
    circval = counter.toDouble() - (counter ~/ 33) * 33;
    circvaltimes = counter ~/ 33;
    prefs.setString('counter', counter.toString());
    //
    update();
  }

  Future minusCounter() async {
    final SharedPreferences prefs = await _sprefs;
    HapticFeedback.heavyImpact();
    //
    counter--;
    if (counter < 0) {
      counter = 0;
    }
    circval = counter.toDouble() - (counter ~/ 33) * 33;
    circvaltimes = counter ~/ 33;
    prefs.setString('counter', counter.toString());
    //
    update();
  }
}
