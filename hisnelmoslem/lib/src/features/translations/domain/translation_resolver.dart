import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';

/// One field of a translation together with the language it is written in.
class ResolvedField extends Equatable {
  final String text;
  final String lang;

  /// True when [lang] is not the language the user asked for.
  final bool isFallback;

  const ResolvedField({required this.text, required this.lang, this.isFallback = false});

  @override
  List<Object?> get props => [text, lang, isFallback];
}

/// What to show for one zikr: each field already fell back user language -> English -> nothing.
class ResolvedTranslation extends Equatable {
  final ResolvedField? meaning;
  final ResolvedField? translit;
  final ResolvedField? note;
  final TranslationCoverage coverage;

  const ResolvedTranslation({
    this.meaning,
    this.translit,
    this.note,
    this.coverage = TranslationCoverage.exact,
  });

  bool get isEmpty => meaning == null && translit == null && note == null;

  /// True when some field comes from a language other than the user's.
  bool get usedFallback =>
      (meaning?.isFallback ?? false) ||
      (translit?.isFallback ?? false) ||
      (note?.isFallback ?? false);

  @override
  List<Object?> get props => [meaning, translit, note, coverage];
}

/// Pure rules for choosing the translation language and the text to show.
abstract final class TranslationResolver {
  /// Value of the `translation_lang` setting that follows the device.
  static const String auto = 'auto';
  static const String fallbackLang = 'en';

  /// The language to load. An explicit [setting] wins when [available] has it; an unknown one
  /// (restored from a backup, or a language that was removed) behaves like [auto]. `auto` is
  /// the device language if available, else the app language if it is not Arabic, else English.
  static String resolveLanguage({
    required String? setting,
    required String deviceLang,
    required String appLang,
    required Set<String> available,
  }) {
    if (setting != null && setting != auto && available.contains(setting)) return setting;
    if (available.contains(deviceLang)) return deviceLang;
    if (appLang != 'ar' && available.contains(appLang)) return appLang;
    return fallbackLang;
  }

  /// Default of the meaning, transliteration and titles switches: on unless the device and the
  /// app are both Arabic and no language was picked on purpose.
  static bool defaultShow({
    required String? setting,
    required String deviceLang,
    required String appLang,
  }) {
    final explicit = setting != null && setting != auto;
    return explicit || !(deviceLang == 'ar' && appLang == 'ar');
  }

  /// Picks one text: the user's language, else English (flagged as fallback), else nothing.
  static ResolvedField? resolveText({
    required String userLang,
    required String? user,
    required String? english,
  }) {
    if (user != null && user.isNotEmpty) return ResolvedField(text: user, lang: userLang);
    if (english != null && english.isNotEmpty && userLang != fallbackLang) {
      return ResolvedField(text: english, lang: fallbackLang, isFallback: true);
    }
    return null;
  }

  static ResolvedTranslation resolve({
    required String userLang,
    required ZikrTranslation? user,
    required ZikrTranslation? english,
  }) {
    ResolvedField? pick(String? Function(ZikrTranslation t) field) => resolveText(
      userLang: userLang,
      user: user == null ? null : field(user),
      english: english == null ? null : field(english),
    );

    final meaning = pick((t) => t.meaning);
    final translit = pick((t) => t.translit);
    final note = pick((t) => t.note);
    // The hint belongs to the translation that supplied the meaning.
    final source = (meaning?.isFallback ?? false) ? english : (user ?? english);
    return ResolvedTranslation(
      meaning: meaning,
      translit: translit,
      note: note,
      coverage: source?.coverage ?? TranslationCoverage.exact,
    );
  }
}
