import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/utils/arabic_number.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';

extension ObjectExtension on Object {
  /// Convert Object's non arabic number to arabic one
  ///
  /// Considers [UseHindiDigits] in [Settings]
  String toArabicNumber() {
    final useHindiDigits = sl<AppSettingsRepo>().useHindiDigits;
    return useHindiDigits ? ArabicNumbers.convert(toString()) : toString();
  }

  /// Convert Object's non arabic number to arabic one
  ///
  ///
  String toArabicNumberString() {
    return ArabicNumbers.convert(toString());
  }
}
