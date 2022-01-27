import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/AppManager/NotificationManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsNotifier extends ChangeNotifier {
  String _azkarReadMode = "Page";
  double _fontSize = 2.6;
  double _intialSize = 2.6;
  bool _tashkel = true;

  bool _rCave = true;
  bool _rFastTwice = true;

  AppSettingsNotifier() {
    getAzkarReadModeData();
    getfontSizeData();
    getTashkelStatusData();
    getRemindersData();
    debugPrint("AppSettingsNotifier new one");
  }
  // TO SAVE IN SHAREDPREFRENCES  ///////////////////
  // SharedPreferences
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  ///////////////////////
  //// _azkarReadMode
  //* save azkarMode in pref
  Future saveAzkarReadModeData(String azkarMode) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setString('azkarModeStatus', azkarMode);
    _azkarReadMode = azkarMode;
  }

  //* get from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getAzkarReadModeData() async {
    final SharedPreferences prefs = await _sprefs;
    String? azkarMode = prefs.getString('azkarModeStatus') ?? "Page";
    _azkarReadMode = azkarMode;

    setAzkarReadMode(azkarMode);
    debugPrint("setting provider getAzkarReadModeData: " + azkarMode);

    // _azkarReadMode = azkarMode;
  }

  //* getter
  getAzkarReadMode() {
    debugPrint(_tashkel.toString());
    return _azkarReadMode;
  }

  //* setter
  setAzkarReadMode(String tashkel) {
    tashkel = _azkarReadMode;
    saveAzkarReadModeData(_azkarReadMode);
    notifyListeners();
  }

  toggleAzkarReadMode() {
    if (_azkarReadMode == "Card") {
      _azkarReadMode = "Page";
    } else if (_azkarReadMode == "Page") {
      _azkarReadMode = "Card";
    }
    saveAzkarReadModeData(_azkarReadMode);
    notifyListeners();
  }

  ///////////////////////
  //// _fontSize

  //* save fontsize in pref
  Future savefontSizeData(double fontSize) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setDouble('fontSize', fontSize);
    debugPrint("fontSize provider fontSize from SharedPreferences: " +
        prefs.getDouble('fontSize').toString());
  }

  //* get fontsize from pref
  //* problem when called on main it it always run and print  and don't stop
  Future getfontSizeData() async {
    final SharedPreferences prefs = await _sprefs;
    double fontSize = prefs.getDouble('fontSize') ?? 2.6;
    if (fontSize == 0) {
      fontSize = 2.6;
    } else {
      setfontSize(fontSize);
      debugPrint("fontSize provider fontSize from SharedPreferences: " +
          fontSize.toString());
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
    //fontSize.clamp(1, 5);
    _fontSize = fontSize.clamp(1, 5).toDouble();
    //_fontSize = fontSize;

    savefontSizeData(_fontSize);
    notifyListeners();
  }

  ///////////////////////
  //// _tashkel
  Future saveTashkelStatusData(bool tashkel) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('tashkelStatus', tashkel);
  }

  // To get tashkel
  Future getTashkelStatusData() async {
    final SharedPreferences prefs = await _sprefs;
    bool tashkel = prefs.getBool('tashkelStatus') ?? true;

    setTashkelStatus(tashkel);
    debugPrint("setting provider TashkelStatusData: " + tashkel.toString());
  }

  //* getter
  getTashkelStatus() {
    debugPrint(_tashkel.toString());
    return _tashkel;
  }

  //* setter
  setTashkelStatus(bool tashkel) {
    _tashkel = tashkel;
    saveTashkelStatusData(tashkel);
    notifyListeners();
  }

  //Toogle
  toggleTashkelStatus() {
    _tashkel = !_tashkel;
    saveTashkelStatusData(_tashkel);
    debugPrint("Tashkel toogled");
    notifyListeners();
  }
///////////////////////
  //// Reminders

  Future saveRMorningData(bool rMorning) async {
    final SharedPreferences prefs = await _sprefs;
    prefs.setBool('rMorning', rMorning);
  }

  Future saveRNightData(bool rNight) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('rNight', rNight);
  }

  Future saveRSleepData(bool rSleep) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('rSleep', rSleep);
  }

  Future saveRWakeupData(bool rWakeup) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('rWakeup', rWakeup);
  }

  Future saveRCaveData(bool rCave) async {
    final SharedPreferences prefs = await _sprefs;

    prefs.setBool('rCave', rCave);
  }

  Future saveRFastTwice(bool rFastTwice) async {
    final SharedPreferences prefs = await _sprefs;
    prefs.setBool('rFastTwice', rFastTwice);
  }

  // To get All Reminders
  Future getRemindersData() async {
    final SharedPreferences prefs = await _sprefs;
    bool rCave = prefs.getBool('rCave') ?? true;
    bool rFastTwice = prefs.getBool('rFastTwice') ?? true;

    setRCave(rCave);

    setRFastTwice(rFastTwice);
  }

  setRCave(bool rCave) {
    _rCave = rCave;
    saveRCaveData(_rCave);
    notifyListeners();
    if (_rCave) {
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 5,
          title: "سورة الكهف",
          body:
              "روى الحاكم في المستدرك مرفوعا إن من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين. وصححه الألباني",
          time: Time(9, 00, 0),
          day: Day.friday,
          payload: "الكهف");
    } else if (_rCave) {
      localNotifyManager.cancelNotificationById(id: 5);
    }
  }

  setRFastTwice(bool rFastTwice) {
    _rFastTwice = rFastTwice;
    saveRFastTwice(_rFastTwice);
    notifyListeners();
    if (_rFastTwice) {
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 555,
          title: "صيام غدا الإثنين",
          body:
              "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
          time: Time(21, 00, 0),
          day: Day.sunday,
          payload: "");
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 777,
          title: "صيام غدا الخميس",
          body:
              "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
          time: Time(21, 00, 0),
          day: Day.wednesday,
          payload: "");
    } else if (_rFastTwice) {
      localNotifyManager.cancelNotificationById(id: 6);
      localNotifyManager.cancelNotificationById(id: 7);
    }
  }

  getRCave() {
    return _rCave;
  }

  getRFastTwice() {
    return _rFastTwice;
  }

  toogleRCave() {
    _rCave = !_rCave;
    saveRCaveData(_rCave);
  }

  toogleRFastTwice() {
    _rFastTwice = !_rFastTwice;
    saveRCaveData(_rFastTwice);
  }
}
