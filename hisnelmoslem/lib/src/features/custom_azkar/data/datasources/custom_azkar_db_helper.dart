import 'dart:async';
import 'dart:io';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Owns `custom_azkar.db`. This file is independent from the bundled
/// `hisn_elmoslem.db`, which is never written to by the custom azkar feature.
class CustomAzkarDBHelper {
  static const String dbName = "custom_azkar.db";
  static const int dbVersion = 1;

  /// Table names.
  static const String titlesTable = "custom_titles";
  static const String zikrsTable = "custom_zikrs";
  static const String itemsTable = "custom_title_items";
  static const String alarmsTable = "custom_alarms";

  /// Used by tests (e.g. `inMemoryDatabasePath`). Null in production.
  final String? pathOverride;

  CustomAzkarDBHelper({this.pathOverride});

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<String> getDbPath() async {
    if (pathOverride != null) return pathOverride!;

    if (Platform.isWindows) {
      final dbPath = (await getApplicationSupportDirectory()).path;
      return join(dbPath, dbName);
    }
    return join(await getDatabasesPath(), dbName);
  }

  Future<Database> _initDatabase() async {
    final path = await getDbPath();
    return openDatabase(
      path,
      version: dbVersion,
      onConfigure: (db) => db.execute("PRAGMA foreign_keys = ON"),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    hisnPrint("Create $dbName");

    await db.execute('''
    CREATE TABLE "$titlesTable" (
      "id"	INTEGER NOT NULL,
      "name"	TEXT NOT NULL,
      "description"	TEXT NOT NULL DEFAULT '',
      "source_title_id"	INTEGER,
      "is_favourite"	INTEGER NOT NULL DEFAULT 0,
      "sort_order"	INTEGER NOT NULL DEFAULT 0,
      "created"	TEXT,
      "updated"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');

    await db.execute('''
    CREATE TABLE "$zikrsTable" (
      "id"	INTEGER NOT NULL,
      "content"	TEXT NOT NULL,
      "source"	TEXT NOT NULL DEFAULT '',
      "fadl"	TEXT NOT NULL DEFAULT '',
      "default_count"	INTEGER NOT NULL DEFAULT 1,
      "is_favourite"	INTEGER NOT NULL DEFAULT 0,
      "created"	TEXT,
      "updated"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');

    await db.execute('''
    CREATE TABLE "$itemsTable" (
      "id"	INTEGER NOT NULL,
      "title_id"	INTEGER NOT NULL REFERENCES "$titlesTable"("id") ON DELETE CASCADE,
      "kind"	TEXT NOT NULL CHECK("kind" IN ('custom','original')),
      "ref_id"	INTEGER NOT NULL,
      "sort_order"	INTEGER NOT NULL,
      "count"	INTEGER NOT NULL DEFAULT 1,
      "snap_content"	TEXT,
      "snap_source"	TEXT,
      "snap_fadl"	TEXT,
      "snap_hokm"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');
    await db.execute('CREATE INDEX "idx_items_title" ON "$itemsTable"("title_id", "sort_order");');

    await db.execute('''
    CREATE TABLE "$alarmsTable" (
      "id"	INTEGER NOT NULL,
      "title_id"	INTEGER NOT NULL UNIQUE REFERENCES "$titlesTable"("id") ON DELETE CASCADE,
      "body"	TEXT NOT NULL DEFAULT '',
      "repeat_type"	TEXT NOT NULL,
      "hour"	INTEGER NOT NULL,
      "minute"	INTEGER NOT NULL,
      "is_active"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');
  }

  /// Must be called before the db file is replaced (restore).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
