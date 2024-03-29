import 'dart:async';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

TallyDatabaseHelper tallyDatabaseHelper = TallyDatabaseHelper();

class TallyDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "tally_database.db";
  static const int dbVersion = 1;

  static TallyDatabaseHelper? _databaseHelper;
  static Database? _database;

  /* ************* Singleton Constructor ************* */

  factory TallyDatabaseHelper() {
    _databaseHelper ??= TallyDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  TallyDatabaseHelper._createInstance();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /* ************* Database Creation ************* */

  // init
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  // On create database
  FutureOr<void> _onCreateDatabase(Database db, int version) async {
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
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');
  }

  // On upgrade database version
  FutureOr<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {
    //
  }

  // On downgrade database version
  FutureOr<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {
    //
  }

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
  Future<DbTally> getTallyById({
    required DbTally dbTally,
  }) async {
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
  Future<void> addNewTally({
    required DbTally dbTally,
  }) async {
    final db = await database;
    dbTally.created = DateTime.now();
    dbTally.lastUpdate = DateTime.now();
    await db.insert(
      'data',
      dbTally.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update tally by ID
  Future<void> updateTally({
    required DbTally dbTally,
    required bool updateTime,
  }) async {
    final db = await database;

    if (updateTime) {
      dbTally.lastUpdate = DateTime.now();
    }

    await db.update(
      'data',
      dbTally.toMap(),
      where: "id = ?",
      whereArgs: [dbTally.id],
    );
  }

  // Delete tally by ID
  Future<void> deleteTally({required DbTally dbTally}) async {
    final db = await database;
    await db.delete(
      'data',
      where: "id = ?",
      whereArgs: [dbTally.id],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
