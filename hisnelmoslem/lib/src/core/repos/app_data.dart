import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_day.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';

class AppData {
  final box = GetStorage(kAppStorageKey);

  static final AppData instance = AppData._();

  factory AppData() {
    return instance;
  }
  AppData._();

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
  Future<void> changeReadModeStatus({required bool value}) async =>
      box.write('is_card_read_mode', value);

  ///
  void toggleReadModeStatus() {
    changeReadModeStatus(value: !isCardReadMode);
  }

  ///MARK: Font
  /* ******* Font Size ******* */

  /// get font size default value is 2.6
  double get fontSize => box.read<double>('font_size') ?? 2.6;

  /// set font size
  Future<void> changFontSize(double value) async {
    final double tempValue = value.clamp(1.5, 4);
    await box.write('font_size', tempValue);
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
  Future<void> changFontFamily(String value) async {
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
  Future<void> changAppLocale(String value) async {
    box.write('app_locale', value);
  }

  /// increase font size by .2
  void resetAppLocale() {
    changFontFamily("ar");
  }

  /* ******* Diacritics ******* */

  /// get Diacritics status
  bool get isDiacriticsEnabled => box.read('tashkel_status') ?? true;

  /// set Diacritics status
  Future<void> changDiacriticsStatus({required bool value}) async =>
      box.write('tashkel_status', value);

  ///
  void toggleDiacriticsStatus() {
    changDiacriticsStatus(value: !isDiacriticsEnabled);
  }

  /* ******* Surat al kahf alarm ******* */

  /// get Surat al kahf alarm status
  bool get isCaveAlarmEnabled => box.read('cave_status') ?? false;

  /// set Surat al kahf alarm status
  Future<void> changCaveAlarmStatus({required bool value}) async {
    await box.write('cave_status', value);
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
  Future<void> changFastAlarmStatus({required bool value}) async {
    await box.write('fast_status', value);
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
  Future<void> changIsFirstOpenToThisRelease({required bool value}) async {
    await box.write("is_${appVersion}_first_open", value);
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
        time: Time(20),
        weekday: AwesomeDay.sunday.value,
        payload: "555",
        needToOpen: false,
      );
      awesomeNotificationManager.addCustomWeeklyReminder(
        id: 666,
        title: "صيام غدا الخميس",
        body:
            "قال رسول الله صلى الله عليه وسلم :\n تُعرضُ الأعمالُ يومَ الإثنين والخميسِ فأُحِبُّ أن يُعرضَ عملي وأنا صائمٌ ",
        time: Time(20),
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
        time: Time(
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

  ///MARK:Hinidi Digits
  /* ******* Hinidi Digits ******* */

  static const String _useHindiDigitsKey = "useHindiDigits";
  bool get useHindiDigits => box.read(_useHindiDigitsKey) ?? false;

  Future<void> changeUseHindiDigits({required bool use}) async =>
      await box.write(_useHindiDigitsKey, use);

  Future toggleUseHindiDigits() async {
    await changeUseHindiDigits(use: !useHindiDigits);
  }

  ///MARK:WakeLock
  /* ******* WakeLock ******* */

  static const String _enableWakeLockKey = "enableWakeLock";
  bool get enableWakeLock => box.read(_enableWakeLockKey) ?? false;

  Future<void> changeEnableWakeLock({required bool use}) async =>
      box.write(_enableWakeLockKey, use);

  void toggleEnableWakeLock() {
    changeEnableWakeLock(use: !enableWakeLock);
  }

  ///MARK: Share as image data

  static const String _shareImageTitleTextBoxKey =
      'share_image_title_text_color';

  Color get shareImageTitleTextColor => Color(
        box.read<int?>(_shareImageTitleTextBoxKey) ??
            kShareImageColorsList[4].value,
      );
  Future<void> shareImageUpdateTitleColor(Color color) async {
    await box.write(_shareImageTitleTextBoxKey, color.value);
  }

  ///
  static const String _shareImageBodyTextColorBoxKey =
      'share_image_body_text_color';

  Color get shareImageBodyTextColor => Color(
        box.read<int?>(_shareImageBodyTextColorBoxKey) ??
            kShareImageColorsList[5].value,
      );

  Future<void> shareImageUpdateTextColor(Color color) async {
    await box.write(_shareImageBodyTextColorBoxKey, color.value);
  }

  ///
  static const String _shareImageAdditionalTextColorBoxKey =
      'share_image_additional_text_color';

  Color get shareImageAdditionalTextColor => Color(
        box.read<int?>(_shareImageAdditionalTextColorBoxKey) ??
            kShareImageColorsList[3].value,
      );
  Future<void> updateAdditionalTextColor(Color color) async {
    await box.write(_shareImageAdditionalTextColorBoxKey, color.value);
  }

  ///
  static const String _shareImageBackgroundColorBoxKey =
      'share_image_background_color';

  Color get shareImageBackgroundColor => Color(
        box.read<int?>(_shareImageBackgroundColorBoxKey) ??
            kShareImageColorsList[7].value,
      );
  Future<void> updateBackgroundColor(Color color) async {
    await box.write(_shareImageBackgroundColorBoxKey, color.value);
  }

  ///
  static const String _shareImageFontSizeBoxKey = 'share_image_font_size';

  double get shareImageFontSize => box.read(_shareImageFontSizeBoxKey) ?? 25;
  Future<void> shareImageChangFontSize(double value) async {
    await box.write(_shareImageFontSizeBoxKey, value);
  }

  ///
  static const String _shareImageShowFadlBoxKey = 'share_image_show_fadl';

  bool get shareImageShowFadl => box.read(_shareImageShowFadlBoxKey) ?? true;
  Future<void> shareImageUpdateShowFadl({required bool value}) async {
    await box.write(_shareImageShowFadlBoxKey, value);
  }

  ///
  static const String _shareImageShowSourceBoxKey = 'share_image_show_source';

  bool get shareImageShowSource =>
      box.read(_shareImageShowSourceBoxKey) ?? true;

  Future<void> shareImageUpdateShowSource({required bool value}) async {
    await box.write(_shareImageShowSourceBoxKey, value);
  }

  ///
  static const String _shareImageShowZikrIndexBoxKey =
      'share_image_show_zikr_index';

  bool get shareImageShowZikrIndex =>
      box.read(_shareImageShowZikrIndexBoxKey) ?? true;
  Future<void> shareImageUpdateShowZikrIndex({required bool value}) async {
    await box.write(_shareImageShowZikrIndexBoxKey, value);
  }

  ///
  static const String _shareImageRemoveDiacriticsKey =
      'share_image_remove_tashkel';

  bool get shareImageRemoveDiacritics =>
      box.read(_shareImageRemoveDiacriticsKey) ?? false;
  Future<void> shareImageUpdateRemoveDiacritics({required bool value}) async {
    await box.write(
      _shareImageRemoveDiacriticsKey,
      value,
    );
  }

  ///
  static const String _shareImageImageWidthBoxKey = 'share_image_image_width';

  int get shareImageImageWidth => box.read(_shareImageImageWidthBoxKey) ?? 600;
  Future<void> shareImageUpdateImageWidth({required int value}) async {
    await box.write(_shareImageImageWidthBoxKey, value);
  }

  ///
  static const String _shareImageImageQualityBoxKey =
      'share_image_image_quality';

  double get shareImageImageQuality =>
      box.read(_shareImageImageQualityBoxKey) ?? 2;
  Future<void> shareImageUpdateImageQuality(double value) async {
    await box.write(_shareImageImageQualityBoxKey, value);
  }

  ///
  static const String _shareImageSettingsBoxKey = 'share_image_image_settings';

  ShareImageSettings get shareImageSettings {
    final data = box.read<String?>(_shareImageSettingsBoxKey);
    if (data == null) {
      return ShareImageSettings(
        titleTextColor: shareImageTitleTextColor,
        bodyTextColor: shareImageBodyTextColor,
        additionalTextColor: shareImageAdditionalTextColor,
        backgroundColor: shareImageBackgroundColor,
        fontSize: shareImageFontSize,
        showFadl: shareImageShowFadl,
        showSource: shareImageShowSource,
        showZikrIndex: shareImageShowZikrIndex,
        removeDiacritics: shareImageRemoveDiacritics,
        imageWidth: shareImageImageWidth,
        imageQuality: shareImageImageQuality,
      );
    }
    return ShareImageSettings.fromJson(data);
  }

  Future<void> updateShareImageSettings(ShareImageSettings settings) async {
    await box.write(
      _shareImageSettingsBoxKey,
      settings.toJson(),
    );
  }
}
