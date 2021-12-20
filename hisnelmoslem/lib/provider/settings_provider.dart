import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsNotifier extends ChangeNotifier {
  bool _tashkel = true;

  //* TO SAVE IN SHAREDPREFRENCES  ///////////////////
  //* SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  //* save fontsize in pref
  Future saveTashkelStatusData(bool tashkel) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('tashkelStatus', tashkel);
  }

  //* get from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getTashkelStatusData() async {
    final SharedPreferences prefs = await _sprefs;
    bool tashkel = prefs.getBool('tashkelStatus');
    if (tashkel == null) {
      tashkel = true;
    } else {
      this.setTashkelStatus(tashkel);
      // print("setting provider TashkelStatusData: " + tashkel.toString());
    }
  }

  //* getter
  getTashkelStatus() {
    //print(_tashkel);
    return _tashkel;
  }

  //* setter
  setTashkelStatus(bool tashkel) {
    tashkel = _tashkel;
    saveTashkelStatusData(tashkel);
    notifyListeners();
  }

  toggleTashkelStatus() {
    _tashkel = !_tashkel;
    saveTashkelStatusData(_tashkel);
    notifyListeners();
  }
}
