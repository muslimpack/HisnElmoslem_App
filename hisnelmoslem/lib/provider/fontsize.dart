import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeNotifier extends ChangeNotifier {
  double _fontSize = 2.6;
  double _intialSize = 2.6;

  //* TO SAVE FONTSIZE IN SHAREDPREFRENCES  ///////////////////
  //* SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  //* save fontsize in pref
  Future savefontSizeData(double fontSize) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setDouble('fontSize', fontSize);
    //print("fontSize provider fontSize from SharedPreferences: " + prefs.getDouble('fontSize').toString());
  }

  //* get fontsize from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getfontSizeData() async {
    final SharedPreferences prefs = await _sprefs;
    double fontSize = prefs.getDouble('fontSize');
    if (fontSize == null || fontSize == 0) {
      fontSize = 2.6;
    } else {
      this.setfontSize(fontSize);
      // print("fontSize provider fontSize from SharedPreferences: " +fontSize.toString());
    }
  }

  //getter
  getfontSize() {
    return _fontSize;
  }

  getIntialSize() {
    return _intialSize;
  }

  //setter
  setfontSize(double fontSize) {
    _fontSize = fontSize;
    savefontSizeData(_fontSize);
    notifyListeners();
  }
}
