import 'package:hisnelmoslem/src/core/utils/arabic_number.dart';

extension ObjectExtension on Object {
  /// Convert Object's non arabic number to arabic one
  String toArabicNumber() {
    return ArabicNumbers.convert(toString());
  }
}
