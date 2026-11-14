import 'package:hisnelmoslem/src/features/translations/data/translations_db_helper.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_language.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';

/// Reads the bundled translations. Everything is loaded per language so the UI can look
/// texts up from memory.
class TranslationsRepo {
  final TranslationsDBHelper dbHelper;
  const TranslationsRepo(this.dbHelper);

  Future<List<TranslationLanguage>> getLanguages() async {
    final db = await dbHelper.database;
    final rows = await db.query(
      TranslationsDBHelper.languagesTable,
      orderBy: 'sort_order ASC, code ASC',
    );
    return rows.map(TranslationLanguage.fromMap).toList();
  }

  /// Translated titles of [lang], by app title id.
  Future<Map<int, String>> getTitles(String lang) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      TranslationsDBHelper.titlesTable,
      where: 'lang = ?',
      whereArgs: [lang],
    );
    return {
      for (final r in rows)
        if (((r['name'] as String?)?.trim() ?? "").isNotEmpty)
          r['title_id']! as int: (r['name']! as String).trim(),
    };
  }

  /// Translated zikrs of [lang], by app content id.
  Future<Map<int, ZikrTranslation>> getContents(String lang) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      TranslationsDBHelper.contentsTable,
      where: 'lang = ?',
      whereArgs: [lang],
    );
    return {for (final r in rows) r['content_id']! as int: ZikrTranslation.fromMap(r)};
  }
}
