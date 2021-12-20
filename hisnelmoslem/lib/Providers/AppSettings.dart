import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/Notification/NotificationManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsNotifier extends ChangeNotifier {
  String _azkarReadMode = "Page";
  double _fontSize = 2.6;
  double _intialSize = 2.6;
  bool _tashkel = true;

  //
  bool _rMorning = false;
  bool _rNight = false;
  bool _rSleep = false;
  bool _rWakeup = false;
  bool _rCave = false;

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
    String azkarMode = prefs.getString('azkarModeStatus');
    _azkarReadMode = azkarMode;

    if (azkarMode == null) {
      azkarMode = 'Page';
    } else {
      this.setAzkarReadMode(azkarMode);
      print("setting provider getAzkarReadModeData: " + azkarMode);
    }
    _azkarReadMode = azkarMode;
  }

  //* getter
  getAzkarReadMode() {
    //print(_tashkel);
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

  //Toogle
  toggleTashkelStatus() {
    _tashkel = !_tashkel;
    saveTashkelStatusData(_tashkel);
    print("Tacshkel toogled");
    notifyListeners();
  }

  ///////////////////////
  //// Reminders

  // Future saveRemindersData(bool rMorning , bool rNight ,bool rSleep ,bool rWakeup , bool rCave ) async {
  //   final SharedPreferences prefs = await _sprefs;
  //   prefs.setBool('rMorning', rMorning);
  //   prefs.setBool('rNight', rNight);
  //   prefs.setBool('rSleep', rSleep);
  //   prefs.setBool('rWakeup', rWakeup);
  //   prefs.setBool('rCave', rCave);
  // }
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

  // To get All Reminders
  Future getRemindersData() async {
    final SharedPreferences prefs = await _sprefs;
    bool rMorning = prefs.getBool('rMorning');
    bool rNight = prefs.getBool('rNight');
    bool rSleep = prefs.getBool('rSleep');
    bool rWakeup = prefs.getBool('rWakeup');
    bool rCave = prefs.getBool('rCave');

    if (rMorning == null) {
      rMorning = true;
    } else {
      this.setRMorning(rMorning);
    }
    if (rNight == null) {
      rNight = true;
    } else {
      this.setRNight(rNight);
    }
    if (rSleep == null) {
      rSleep = true;
    } else {
      this.setRSleep(rSleep);
    }
    if (rWakeup == null) {
      rWakeup = true;
    } else {
      this.setRWakeup(rWakeup);

    }
    if (rCave == null) {
      rCave = true;
    } else {
      this.setRCave(rCave);

    }
  }

  setRMorning(bool rMorning) {
    _rMorning = rMorning;
    saveRMorningData(_rMorning);
    notifyListeners();
    if (_rMorning) {
      localNotifyManager.customDailyReminder(channelName: "تنبيهات الأذكار", id: 1, title: "أذكار الصباح", time: Time(6,00,0));
    } else if (_rMorning) {
      localNotifyManager.cancelNotification(1);
    }
  }

  setRNight(bool rNight) {
    _rNight = rNight;
    saveRNightData(_rNight);
    notifyListeners();
    if (_rNight) {
      localNotifyManager.customDailyReminder(channelName: "تنبيهات الأذكار", id: 2, title: "أذكار المساء", time: Time(16,00,0));
    } else if (_rNight) {
      localNotifyManager.cancelNotification(2);
    }
  }

  setRSleep(bool rSleep) {
    _rSleep = rSleep;
    saveRSleepData(_rSleep);
    notifyListeners();
    if (_rSleep) {
      localNotifyManager.customDailyReminder(channelName: "تنبيهات الأذكار", id: 3, title: "أذكار النوم", time: Time(21,00,0));
    } else if (_rSleep) {
      localNotifyManager.cancelNotification(3);
    }
  }

  setRWakeup(bool rWakeup) {
    _rWakeup = rWakeup;
    saveRWakeupData(_rWakeup);
    notifyListeners();
    if (_rSleep) {
      localNotifyManager.customDailyReminder(channelName: "تنبيهات الأذكار", id: 4, title: "أذكار الاستيقاظ", time: Time(4,30,0));
    } else if (_rSleep) {
      localNotifyManager.cancelNotification(4);
    }
  }

  setRCave(bool rCave) {
    _rCave = rCave;
    saveRCaveData(_rCave);
    notifyListeners();
    if (_rCave) {
      localNotifyManager.customWeeklyReminder(channelName: "تنبيهات الأذكار", id: 5, title: "سورة الكهف", time: Time(9,00,0), day: Day.friday,payload: "الكهف");
    } else if (_rCave) {
      localNotifyManager.cancelNotification(5);
    }
  }

  getRMorning() {
    return _rMorning;
  }

  getRNight() {
    return _rNight;
  }

  getRSleep() {
    return _rSleep;
  }

  getRWakeup() {
    return _rWakeup;
  }

  getRCave() {
    return _rCave;
  }

  toogleRMorning() {
    _rMorning = !_rMorning;
    saveRMorningData(_rMorning);
  }

  toogleRNight() {
    _rNight = !_rNight;
    saveRNightData(_rNight);
  }

  toogleRSleep() {
    _rSleep = !_rSleep;
    saveRSleepData(_rSleep);
  }

  toogleRWakeup() {
    _rWakeup = !_rWakeup;
    saveRWakeupData(_rWakeup);
  }

  toogleRCave() {
    _rCave = !_rCave;
    saveRCaveData(_rCave);
  }


}
