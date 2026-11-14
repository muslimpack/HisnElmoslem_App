import 'package:hisnelmoslem/src/features/translations/data/translations_db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens an in-memory database with the schema of `assets/db/translations.db` and a few rows.
Future<Database> openTranslationsFixture() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE languages(code TEXT PRIMARY KEY, name_native TEXT NOT NULL,
      name_en TEXT NOT NULL, is_rtl INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL,
      source TEXT NOT NULL, source_url TEXT, has_meaning INTEGER NOT NULL,
      has_translit INTEGER NOT NULL)''');
  await db.execute('''
    CREATE TABLE title_translations(title_id INTEGER NOT NULL, lang TEXT NOT NULL,
      name TEXT NOT NULL, PRIMARY KEY(title_id, lang)) WITHOUT ROWID''');
  await db.execute('''
    CREATE TABLE content_translations(content_id INTEGER NOT NULL, lang TEXT NOT NULL,
      meaning TEXT, translit TEXT, note TEXT, fadl TEXT,
      coverage TEXT NOT NULL DEFAULT 'exact', PRIMARY KEY(content_id, lang)) WITHOUT ROWID''');

  await db.insert('languages', {
    'code': 'fr',
    'name_native': 'Français',
    'name_en': 'French',
    'sort_order': 2,
    'source': 'hisnmuslim.com',
    'has_meaning': 1,
    'has_translit': 0,
  });
  await db.insert('languages', {
    'code': 'en',
    'name_native': 'English',
    'name_en': 'English',
    'sort_order': 1,
    'source': 'hisnmuslim.com',
    'source_url': 'https://hisnmuslim.com',
    'has_meaning': 1,
    'has_translit': 1,
  });
  await db.insert('title_translations', {'title_id': 1, 'lang': 'en', 'name': 'Waking up'});
  await db.insert('title_translations', {'title_id': 1, 'lang': 'fr', 'name': 'Au réveil'});
  await db.insert('title_translations', {'title_id': 2, 'lang': 'en', 'name': 'Clothes'});
  await db.insert('content_translations', {
    'content_id': 10,
    'lang': 'en',
    'meaning': 'All praise is for Allah',
    'translit': 'Alhamdu lillah',
    'coverage': 'exact',
  });
  await db.insert('content_translations', {
    'content_id': 10,
    'lang': 'fr',
    'meaning': 'Louange à Allah',
    'translit': '  ',
    'coverage': 'partial',
  });
  await db.insert('content_translations', {
    'content_id': 11,
    'lang': 'en',
    'meaning': 'Only English',
    'note': 'Recite once',
    'coverage': 'near',
  });
  return db;
}

TranslationsDBHelper fixtureHelper() => TranslationsDBHelper(opener: openTranslationsFixture);
