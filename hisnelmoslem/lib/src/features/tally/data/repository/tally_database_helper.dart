import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TallyDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "tally_database.db";
  static const int dbVersion = 2;

  static TallyDatabaseHelper? _databaseHelper;
  static Database? _database;

  /* ************* Singleton Constructor ************* */

  factory TallyDatabaseHelper() {
    _databaseHelper ??= TallyDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  TallyDatabaseHelper._createInstance();

  /// Uses an already open [db] (tests give an in-memory database).
  @visibleForTesting
  TallyDatabaseHelper.withDatabase(Database db) {
    _database = db;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /* ************* Database Creation ************* */

  Future<String> getDbPath() async {
    late final String path;

    if (Platform.isWindows) {
      final dbPath = (await getApplicationSupportDirectory()).path;
      path = join(dbPath, dbName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }

    return path;
  }

  // init
  Future<Database> _initDatabase() async {
    final path = await getDbPath();

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  // On create database
  Future<void> _onCreateDatabase(Database db, int version) => createSchema(db);

  @visibleForTesting
  static Future<void> createSchema(Database db) async {
    hisnPrint("Create tally.db");

    /// Create data table
    await db.execute('''
    CREATE TABLE "data" (
      "id"	INTEGER NOT NULL UNIQUE,
      "title"	TEXT,
      "count"	INTEGER DEFAULT 0,
      "created"	TEXT,
      "lastUpdate"	TEXT,
      "isActivated"	INTEGER DEFAULT 0,
      "countReset"	INTEGER DEFAULT 33,
      "description"	TEXT,
      "audioFile"	TEXT DEFAULT '',
      "advanceTrigger"	TEXT DEFAULT 'perCount',
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');
  }

  // On upgrade database version
  Future<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) => upgradeSchema(db, oldVersion);

  @visibleForTesting
  static Future<void> upgradeSchema(Database db, int oldVersion) async {
    if (oldVersion < 2) {
      // Voice recording and per-counter auto-advance. Existing counters keep the
      // old behaviour: no recording, advance after every count.
      await db.execute("ALTER TABLE data ADD COLUMN audioFile TEXT DEFAULT ''");
      await db.execute("ALTER TABLE data ADD COLUMN advanceTrigger TEXT DEFAULT 'perCount'");
    }
  }

  // On downgrade database version
  Future<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  /* ************* Functions ************* */

  // Get all tally from database
  Future<List<DbTally>> getAllTally() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('data');

    return List.generate(maps.length, (i) {
      return DbTally.fromMap(maps[i]);
    });
  }

  // Get all tally by id from database
  Future<DbTally> getTallyById({required DbTally dbTally}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'data',
      where: "id = ?",
      whereArgs: [dbTally.id],
    );

    return List.generate(maps.length, (i) {
      return DbTally.fromMap(maps[i]);
    }).first;
  }

  // Add new tally to database
  Future<int> addNewTally({required DbTally dbTally}) async {
    final db = await database;
    return db.insert(
      'data',
      dbTally.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update tally by ID
  Future<void> updateTally({required DbTally dbTally}) async {
    final db = await database;

    await db.update(
      'data',
      dbTally.toMap(),
      where: "id = ?",
      whereArgs: [dbTally.id],
    );
  }

  Future<void> updateTallies({required List<DbTally> dbTallies}) async {
    final db = await database;

    final batch = db.batch();

    for (final dbTally in dbTallies) {
      batch.update(
        'data',
        dbTally.copyWith(lastUpdate: DateTime.now()).toMap(),
        where: "id = ?",
        whereArgs: [dbTally.id],
      );
    }

    await batch.commit(noResult: true);
  }

  // Delete tally by ID
  Future<void> deleteTally({required DbTally dbTally}) async {
    final db = await database;
    await db.delete('data', where: "id = ?", whereArgs: [dbTally.id]);
  }

  /// Names of the recordings the counters point to.
  Future<Set<String>> referencedAudioFiles() async {
    final db = await database;
    final rows = await db.query('data', columns: ['audioFile']);
    return {
      for (final row in rows)
        if (((row['audioFile'] as String?) ?? "").isNotEmpty) row['audioFile']! as String,
    };
  }

  // Close database
  Future close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
