import 'package:equatable/equatable.dart';

/// A row of the `languages` table of `translations.db`.
class TranslationLanguage extends Equatable {
  final String code;
  final String nameNative;
  final String nameEn;
  final bool isRtl;
  final int sortOrder;

  /// Who the translation comes from (shown as a credit in the language sheet).
  final String source;
  final String? sourceUrl;
  final bool hasMeaning;
  final bool hasTranslit;

  const TranslationLanguage({
    required this.code,
    required this.nameNative,
    required this.nameEn,
    this.isRtl = false,
    this.sortOrder = 0,
    this.source = "",
    this.sourceUrl,
    this.hasMeaning = true,
    this.hasTranslit = true,
  });

  factory TranslationLanguage.fromMap(Map<String, Object?> map) {
    return TranslationLanguage(
      code: map['code']! as String,
      nameNative: map['name_native']! as String,
      nameEn: map['name_en']! as String,
      isRtl: (map['is_rtl'] as int? ?? 0) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      source: (map['source'] as String?) ?? "",
      sourceUrl: map['source_url'] as String?,
      hasMeaning: (map['has_meaning'] as int? ?? 1) == 1,
      hasTranslit: (map['has_translit'] as int? ?? 1) == 1,
    );
  }

  @override
  List<Object?> get props => [
    code,
    nameNative,
    nameEn,
    isRtl,
    sortOrder,
    source,
    sourceUrl,
    hasMeaning,
    hasTranslit,
  ];
}
