import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

/// A language the app interface is available in, with its own native name.
class AppLanguage {
  final String code;

  /// The name in the language itself; never translated through the ARB files.
  final String nativeName;
  final bool isRtl;

  const AppLanguage({required this.code, required this.nativeName, this.isRtl = false});

  Locale get locale => Locale(code);
}

/// The interface languages and the rules to pick one from a stored or device language code.
abstract final class AppLanguages {
  static const String fallbackCode = 'ar';

  static const List<AppLanguage> all = [
    AppLanguage(code: 'ar', nativeName: 'العربية', isRtl: true),
    AppLanguage(code: 'en', nativeName: 'English'),
    AppLanguage(code: 'fr', nativeName: 'Français'),
  ];

  static List<String> get codes => [for (final language in all) language.code];

  /// True when [code] is a language the app has localizations for.
  static bool isSupported(String? code) =>
      code != null && S.supportedLocales.any((locale) => locale.languageCode == code);

  /// The language for [code], or null when it is not one of [all].
  static AppLanguage? byCode(String? code) {
    for (final language in all) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// The native name of [code]; the code itself when it is unknown.
  static String nativeNameOf(String code) => byCode(code)?.nativeName ?? code;

  /// [code] when supported (a region such as `fr_FR` or `fr-CA` is dropped), else [fallbackCode].
  static String resolveCode(String? code) {
    final language = code?.split(RegExp('[_-]')).first.toLowerCase();
    return isSupported(language) ? language! : fallbackCode;
  }
}
