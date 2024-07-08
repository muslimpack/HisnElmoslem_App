import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/utils/arabic_number.dart';

extension ObjectExtension on Object {
  /// Convert Object's non arabic number to arabic one
  ///
  /// Considers [UseHindiDigits] in [Settings]
  String toArabicNumber() {
    final useHindiDigits = appData.useHindiDigits;
    return useHindiDigits ? ArabicNumbers.convert(toString()) : toString();
  }

  /// Convert Object's non arabic number to arabic one
  ///
  ///
  String toArabicNumberString() {
    return ArabicNumbers.convert(toString());
  }
}
