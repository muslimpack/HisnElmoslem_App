import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarMode extends ChangeNotifier {
  String _azkarMode = "Card";

  //* TO SAVE IN SHAREDPREFRENCES  ///////////////////
  //* SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  //* save azkarMode in pref
  Future saveAzkarModeData(String azkarMode) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setString('azkarModeStatus', azkarMode);
  }

  //* get from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getAzkarModeData() async {
    final SharedPreferences prefs = await _sprefs;
    String azkarMode = prefs.getString('azkarMode');
    if (azkarMode == null) {
      azkarMode = 'Card';
    } else {
      this.setAzkarMode(azkarMode);
      // print("setting provider TashkelStatusData: " + tashkel.toString());
    }
  }

  //* getter
  getAzkarMode() {
    //print(_tashkel);
    return _azkarMode;
  }

  //* setter
  setAzkarMode(String tashkel) {
    tashkel = _azkarMode;
    saveAzkarModeData(_azkarMode);
    notifyListeners();
  }

  toggleAzkarMode() {
    if (_azkarMode == "Card") {
      _azkarMode = "Page";
    } else if (_azkarMode == "Page") {
      _azkarMode = "Card";
    }
    saveAzkarModeData(_azkarMode);
    notifyListeners();
  }
}
