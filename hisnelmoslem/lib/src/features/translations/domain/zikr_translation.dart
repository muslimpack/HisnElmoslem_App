import 'package:equatable/equatable.dart';

/// How well a translation fits the app's zikr (`content_translations.coverage`).
enum TranslationCoverage {
  exact,
  near,

  /// The app zikr spans several items of the source.
  combined,

  /// The app zikr is only a piece of the source item, so the translation may say more.
  partial;

  static TranslationCoverage parse(String? value) {
    return TranslationCoverage.values.where((e) => e.name == value).firstOrNull ??
        TranslationCoverage.exact;
  }
}

/// A row of `content_translations`. Empty fields are stored as `null`.
class ZikrTranslation extends Equatable {
  final int contentId;
  final String lang;
  final String? meaning;
  final String? translit;
  final String? note;
  final String? fadl;
  final TranslationCoverage coverage;

  const ZikrTranslation({
    required this.contentId,
    required this.lang,
    this.meaning,
    this.translit,
    this.note,
    this.fadl,
    this.coverage = TranslationCoverage.exact,
  });

  factory ZikrTranslation.fromMap(Map<String, Object?> map) {
    String? text(String key) {
      final value = (map[key] as String?)?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    return ZikrTranslation(
      contentId: map['content_id']! as int,
      lang: map['lang']! as String,
      meaning: text('meaning'),
      translit: text('translit'),
      note: text('note'),
      fadl: text('fadl'),
      coverage: TranslationCoverage.parse(map['coverage'] as String?),
    );
  }

  @override
  List<Object?> get props => [contentId, lang, meaning, translit, note, fadl, coverage];
}
