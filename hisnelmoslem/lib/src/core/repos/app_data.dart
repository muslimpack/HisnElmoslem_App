import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';

class AppData {
  final box = GetStorage(kAppStorageKey);

  static final AppData instance = AppData._();

  factory AppData() {
    return instance;
  }
  AppData._();

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

  /* ******* Share as image ******* */

  /* ******* is first open to this release ******* */
  /// Check is first open to this release
  bool get isFirstOpenToThisRelease =>
      box.read("is_${appVersion}_first_open") ?? true;

  /// Change is first open to this release
  Future<void> changIsFirstOpenToThisRelease({required bool value}) async {
    await box.write("is_${appVersion}_first_open", value);
  }
}
