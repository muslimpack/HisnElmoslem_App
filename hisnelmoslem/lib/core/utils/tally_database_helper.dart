import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

TallyDatabaseHelper tallyDatabaseHelper = TallyDatabaseHelper();

class TallyDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "tally_database.db";
  static const int dbVersion = 1;

  static TallyDatabaseHelper? _databaseHelper;
  static Database? _database;

  /* ************* Singelton Constractor ************* */

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

    final exist = await databaseExists(path);

    //Check if database is already in that Directory
    if (!exist) {
      // Database isn't exist > Create new Database
      await _copyFromAssets(path: path);
    }

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
    //
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

  // Copy database from assets to Database Direcorty of app
  FutureOr<void> _copyFromAssets({required String path}) async {
    //
    try {
      await Directory(dirname(path)).create(recursive: true);

      final ByteData data = await rootBundle.load(join("assets", "db", dbName));
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      hisnPrint(e.toString());
    }
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
