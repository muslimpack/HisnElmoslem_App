import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/utils/notification_manager.dart';

class AppDataController extends GetxController {
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
  void changeReadModeStatus(bool val) => box.write('is_card_read_mode', val);

  ///
  void toggleReadModeStatus() {
    changeReadModeStatus(!isCardReadMode);
  }

  /* ******* Font Size ******* */

  /// get font size default value is 2.6
  double get fontSize => box.read('font_size') ?? 2.6;

  /// set font size
  void changFontSize(double value) {
    value = value.clamp(1.5, 4);
    box.write('font_size', value);
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

  /* ******* Tashkel ******* */

  /// get tashkel status
  bool get isTashkelEnabled => box.read('tashkel_status') ?? true;

  /// set tashkel status
  void changTashkelStatus(bool value) => box.write('tashkel_status', value);

  ///
  void toggleTashkelStatus() {
    changTashkelStatus(!isTashkelEnabled);
  }

  /* ******* Surat al kahf alarm ******* */

  /// get Surat al kahf alarm status
  bool get isCaveAlarmEnabled => box.read('cave_status') ?? false;

  /// set Surat al kahf alarm status
  void changCaveAlarmStatus(bool value) {
    box.write('cave_status', value);
    _activateCaveAlarm(value: value);
  }

  ///
  void toggleCaveAlarmStatus() {
    changCaveAlarmStatus(!isCaveAlarmEnabled);
  }

  /* ******* monday and thursday fast alarm ******* */

  /// get monday and thursday fast alarm alarm status
  bool get isFastAlarmEnabled => box.read('fast_status') ?? false;

  /// set monday and thursday fast alarm alarm status
  void changFastAlarmStatus(bool value) {
    box.write('fast_status', value);
    _activateFastAlarm(value: value);
  }

  ///
  void toggleFastAlarmStatus() {
    changFastAlarmStatus(!isFastAlarmEnabled);
  }

  /**
   * Function to active and disable constant alarms 
   */

  ///
  _activateCaveAlarm({required bool value}) {
    if (value) {
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 555,
          title: "صيام غدا الإثنين",
          body:
              "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
          time: const Time(21, 00, 0),
          day: Day.sunday,
          payload: "555");
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 777,
          title: "صيام غدا الخميس",
          body:
              "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
          time: const Time(21, 00, 0),
          day: Day.wednesday,
          payload: "666");
    } else {
      localNotifyManager.cancelNotificationById(id: 555);
      localNotifyManager.cancelNotificationById(id: 666);
    }
  }

  ///
  _activateFastAlarm({required bool value}) {
    if (value) {
      localNotifyManager.addCustomWeeklyReminder(
          channelName: "تنبيهات الأذكار",
          id: 777,
          title: "سورة الكهف",
          body:
              "روى الحاكم في المستدرك مرفوعا إن من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين. وصححه الألباني",
          time: const Time(9, 00, 0),
          day: Day.friday,
          payload: "الكهف");
    } else {
      localNotifyManager.cancelNotificationById(id: 777);
    }
  }
}
