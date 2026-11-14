part of 'translations_cubit.dart';

class TranslationsState extends Equatable {
  /// False until the first load finished (or failed).
  final bool isLoaded;

  /// The stored choice: `auto` or a language code.
  final String setting;

  /// The language actually in use.
  final String lang;
  final List<TranslationLanguage> languages;
  final bool showMeaning;
  final bool showTranslit;
  final bool showTitles;
  final Map<int, ZikrTranslation> contents;
  final Map<int, ZikrTranslation> englishContents;
  final Map<int, String> titles;
  final Map<int, String> englishTitles;

  const TranslationsState({
    this.isLoaded = false,
    this.setting = TranslationResolver.auto,
    this.lang = TranslationResolver.fallbackLang,
    this.languages = const [],
    this.showMeaning = false,
    this.showTranslit = false,
    this.showTitles = false,
    this.contents = const {},
    this.englishContents = const {},
    this.titles = const {},
    this.englishTitles = const {},
  });

  TranslationLanguage? languageOf(String code) =>
      languages.where((e) => e.code == code).firstOrNull;

  bool isRtl(String code) => languageOf(code)?.isRtl ?? false;

  /// The translation of the zikr with [contentKey] (`DbContent.translationKey`), or `null`
  /// when there is none, or its fields are hidden by the switches.
  ResolvedTranslation? translationFor(int? contentKey) {
    if (contentKey == null || contentKey <= 0 || !(showMeaning || showTranslit)) return null;
    final resolved = TranslationResolver.resolve(
      userLang: lang,
      user: contents[contentKey],
      english: englishContents[contentKey],
    );
    final visible = ResolvedTranslation(
      meaning: showMeaning ? resolved.meaning : null,
      translit: showTranslit ? resolved.translit : null,
      note: resolved.note,
      coverage: resolved.coverage,
    );
    return visible.meaning == null && visible.translit == null ? null : visible;
  }

  /// The translated title shown as a subtitle, or `null` (switch off, custom title, no text).
  ResolvedField? titleFor(int titleId) {
    if (!showTitles || titleId <= 0) return null;
    return TranslationResolver.resolveText(
      userLang: lang,
      user: titles[titleId],
      english: englishTitles[titleId],
    );
  }

  TranslationsState copyWith({
    bool? isLoaded,
    String? setting,
    String? lang,
    List<TranslationLanguage>? languages,
    bool? showMeaning,
    bool? showTranslit,
    bool? showTitles,
    Map<int, ZikrTranslation>? contents,
    Map<int, ZikrTranslation>? englishContents,
    Map<int, String>? titles,
    Map<int, String>? englishTitles,
  }) {
    return TranslationsState(
      isLoaded: isLoaded ?? this.isLoaded,
      setting: setting ?? this.setting,
      lang: lang ?? this.lang,
      languages: languages ?? this.languages,
      showMeaning: showMeaning ?? this.showMeaning,
      showTranslit: showTranslit ?? this.showTranslit,
      showTitles: showTitles ?? this.showTitles,
      contents: contents ?? this.contents,
      englishContents: englishContents ?? this.englishContents,
      titles: titles ?? this.titles,
      englishTitles: englishTitles ?? this.englishTitles,
    );
  }

  @override
  List<Object?> get props => [
    isLoaded,
    setting,
    lang,
    languages,
    showMeaning,
    showTranslit,
    showTitles,
    contents,
    englishContents,
    titles,
    englishTitles,
  ];
}
