import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';

class ZikrTextRepo {
  final GetStorage box;
  ZikrTextRepo(this.box);

  ///MARK: Font
  /* ******* Font Size ******* */

  double get fontSize => box.read<double>('font_size') ?? kFontDefault;

  Future<void> changFontSize(double value) async {
    final double tempValue = value.clamp(kFontMin, kFontMax);
    await box.write('font_size', tempValue);
  }

  void resetFontSize() {
    changFontSize(kFontDefault);
  }

  void increaseFontSize() {
    changFontSize(fontSize + kFontChangeBy);
  }

  void decreaseFontSize() {
    changFontSize(fontSize - kFontChangeBy);
  }

  /* ******* Diacritics ******* */

  bool get showDiacritics => box.read('tashkel_status') ?? true;

  Future<void> changDiacriticsStatus({required bool value}) =>
      box.write('tashkel_status', value);
}
