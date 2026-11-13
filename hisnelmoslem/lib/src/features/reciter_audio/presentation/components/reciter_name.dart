import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

extension ReciterName on Reciter {
  /// The name in the app language (Arabic or English).
  String localizedName(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? nameAr : nameEn;
}
