import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarMode extends ChangeNotifier {
  // String _azkarMode;
  String _azkarMode = "Card";

  //* TO SAVE IN SHAREDPREFRENCES  ///////////////////
  //* SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  //* save azkarMode in pref
  Future saveAzkarModeData(String azkarMode) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setString('azkarModeStatus', azkarMode);
    _azkarMode = azkarMode;
  }

  //* get from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getAzkarModeData() async {
    final SharedPreferences prefs = await _sprefs;
    String azkarMode = prefs.getString('azkarModeStatus');
    _azkarMode = azkarMode;

    if (azkarMode == null) {
      azkarMode = 'Card';
    } else {
      this.setAzkarMode(azkarMode);
      print("setting provider TashkelStatusData: " + azkarMode);
    }
    _azkarMode = azkarMode;
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
