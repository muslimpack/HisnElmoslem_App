import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Read-only bundled `assets/db/translations.db`, copied like the other bundled databases.
class TranslationsDBHelper {
  static const String dbName = "translations.db";

  /// Must equal `PRAGMA user_version` of the bundled file.
  static const int dbVersion = 1;

  static const String languagesTable = "languages";
  static const String titlesTable = "title_translations";
  static const String contentsTable = "content_translations";

  final Future<Database> Function() _opener;
  Database? _database;

  /// [opener] lets tests supply a fixture database instead of the bundled asset.
  TranslationsDBHelper({Future<Database> Function()? opener})
    : _opener = opener ?? DBHelper(dbName: dbName, dbVersion: dbVersion).initDatabase;

  Future<Database> get database async => _database ??= await _opener();

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
