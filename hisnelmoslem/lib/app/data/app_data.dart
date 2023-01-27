import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/awesome_day.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

AppData appData = AppData();

class AppData {
  final box = GetStorage();

  /* ******* Azkar Read Mode ******* */

  /// get Zikr Page mode
  /// If it is true then
  /// page mode will be card mode
  /// if not page mode will be page
  bool get isCardReadMode => box.read('is_card_read_mode') ?? false;

  /// set Zikr Page mode
  /// If it is true then
  /// page mode will be card mode
  /// if not page mode will be page
  void changeReadModeStatus({required bool value}) =>
      box.write('is_card_read_mode', value);

  ///
  void toggleReadModeStatus() {
    changeReadModeStatus(value: !isCardReadMode);
  }

  /* ******* Font Size ******* */

  /// get font size default value is 2.6
  double get fontSize => box.read('font_size') ?? 2.6;

  /// set font size
  void changFontSize(double value) {
    box.write('font_size', value.clamp(1.5, 4));
  }

  /// increase font size by .2
  void resetFontSize() {
    changFontSize(2.6);
  }

  /// increase font size by .2
  void increaseFontSize() {
    changFontSize(fontSize + .2);
  }

  /// decrease font size by .2
  void decreaseFontSize() {
    changFontSize(fontSize - .2);
  }

  /* ******* Font Size ******* */

  /// get font size default value is 2.6
  String get fontFamily => box.read('font_family') ?? "Amiri";

  /// set font size
  void changFontFamily(String value) {
    box.write('font_family', value);
  }

  /// increase font size by .2
  void resetFontFamily() {
    changFontFamily("Amiri");
  }
  /* ******* App Locale ******* */

  /// get font size default value is 2.6
  String get appLocale => box.read('app_locale') ?? "ar";

  /// set font size
  void changAppLocale(String value) {
    box.write('app_locale', value);
  }

  /// increase font size by .2
  void resetAppLocale() {
    changFontFamily("ar");
  }

  /* ******* Tashkel ******* */

  /// get tashkel status
  bool get isTashkelEnabled => box.read('tashkel_status') ?? true;

  /// set tashkel status
  void changTashkelStatus({required bool value}) =>
      box.write('tashkel_status', value);

  ///
  void toggleTashkelStatus() {
    changTashkelStatus(value: !isTashkelEnabled);
  }

  /* ******* Surat al kahf alarm ******* */

  /// get Surat al kahf alarm status
  bool get isCaveAlarmEnabled => box.read('cave_status') ?? false;

  /// set Surat al kahf alarm status
  void changCaveAlarmStatus({required bool value}) {
    box.write('cave_status', value);
    _activateCaveAlarm(value: value);
  }

  ///
  void toggleCaveAlarmStatus() {
    changCaveAlarmStatus(value: !isCaveAlarmEnabled);
  }

  /* ******* monday and thursday fast alarm ******* */

  /// get monday and thursday fast alarm alarm status
  bool get isFastAlarmEnabled => box.read('fast_status') ?? false;

  /// set monday and thursday fast alarm alarm status
  void changFastAlarmStatus({required bool value}) {
    box.write('fast_status', value);
    _activateFastAlarm(value: value);
  }

  ///
  void toggleFastAlarmStatus() {
    changFastAlarmStatus(value: !isFastAlarmEnabled);
  }

  /* ******* Share as image ******* */

  /* ******* is first open to this release ******* */
  /// Check is first open to this release
  bool get isFirstOpenToThisRelease =>
      box.read("is_${appVersion}_first_open") ?? true;

  /// Change is first open to this release
  void changIsFirstOpenToThisRelease({required bool value}) {
    box.write("is_${appVersion}_first_open", value);
  }

  /**
   * Function to active and disable constant alarms
   */

  ///
  void _activateCaveAlarm({required bool value}) {
    if (value) {
      awesomeNotificationManager.addCustomWeeklyReminder(
        id: 555,
        title: "صيام غدا الإثنين",
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: const Time(20),
        weekday: AwesomeDay.sunday.value,
        payload: "555",
        needToOpen: false,
      );
      awesomeNotificationManager.addCustomWeeklyReminder(
        id: 666,
        title: "صيام غدا الخميس",
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: const Time(20),
        weekday: AwesomeDay.wednesday.value,
        payload: "666",
        needToOpen: false,
      );
    } else {
      awesomeNotificationManager.cancelNotificationById(id: 555);
      awesomeNotificationManager.cancelNotificationById(id: 666);
    }
  }

  ///
  void _activateFastAlarm({required bool value}) {
    if (value) {
      awesomeNotificationManager.addCustomWeeklyReminder(
        id: 777,
        title: "sura Al-Kahf".tr,
        body:
            "روى الحاكم في المستدرك مرفوعا إن من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين. وصححه الألباني",
        time: const Time(
          9,
        ),
        weekday: AwesomeDay.friday.value,
        payload: "الكهف",
        needToOpen: false,
      );
    } else {
      awesomeNotificationManager.cancelNotificationById(id: 777);
    }
  }
}
