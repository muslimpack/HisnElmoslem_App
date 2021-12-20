import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;
  ThemeNotifier(this._themeData);

  //* TO SAVE THEME IN SHAREDPREFRENCES  ///////////////////
  //* SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  //* save themedata in pref
  Future saveThemeData(ThemeData theme) async {
    final SharedPreferences prefs = await _sprefs;
    String _theme;

    if (theme == ThemeData.dark()) {
      _theme = "dark";
    } else if (theme == ThemeData.light()) {
      _theme = "light";
    }
    prefs.setString('theme', _theme);
    //print("theme provider theme from SharedPreferences: " +prefs.getString('theme'));
  }

  //* save themedata in pref
  //* problem when called on main it it always run and print  and don't stop
  Future getThemeData() async {
    final SharedPreferences prefs = await _sprefs;
    String _theme = prefs.getString('theme');
    //print("theme provider theme from getTheme: " + _theme.toString());
    if (_theme == null) {
      this.setTheme(ThemeData.dark());
    } else if (_theme == "dark") {
      this.setTheme(ThemeData.dark());
    } else if (_theme == "light") {
      this.setTheme(ThemeData.light());
    }
  }

  //getter
  getTheme() {
    return _themeData;
  }

  //setter
  setTheme(ThemeData theme) {
    _themeData = theme;
    saveThemeData(theme);
    notifyListeners();
  }
}
