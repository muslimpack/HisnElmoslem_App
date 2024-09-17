import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

FakeHadithOldDBHelper fakeHadithOldDBHelper = FakeHadithOldDBHelper();

class FakeHadithOldDBHelper {
  /* ************* Variables ************* */

  static const String dbName = "fake_hadith_database.db";
  static const int dbVersion = 1;

  /* ************* Singleton Constructor ************* */

  static FakeHadithOldDBHelper? _databaseHelper;
  static Database? _database;

  factory FakeHadithOldDBHelper() {
    _databaseHelper ??= FakeHadithOldDBHelper._createInstance();
    return _databaseHelper!;
  }

  FakeHadithOldDBHelper._createInstance();

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

  // Copy database from assets to Database Directory of app
  Future<void> _copyFromAssets({required String path}) async {
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
  // Get all hadith from database
  Future<List<DbFakeHaith>> getAllFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    return List.generate(maps.length, (i) {
      return DbFakeHaith.fromMap(maps[i]);
    });
  }

  // Get read hadith only
  Future<List<DbFakeHaith>> getReadFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    return List.generate(maps.length, (i) {
      return DbFakeHaith.fromMap(maps[i]);
    }).where((element) => element.isRead).toList();
  }

  // Get unread hadith only
  Future<List<DbFakeHaith>> getUnreadFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    return List.generate(maps.length, (i) {
      return DbFakeHaith.fromMap(maps[i]);
    }).where((element) => !element.isRead).toList();
  }

  // Mark haduth as read
  Future<void> markAsRead({required DbFakeHaith dbFakeHaith}) async {
    final db = await database;

    await db.rawUpdate(
      'UPDATE fakehadith SET isRead = ? WHERE _id = ?',
      [1, dbFakeHaith.id],
    );
  }

  // Mark hadith as unread
  Future<void> markAsUnRead({required DbFakeHaith dbFakeHaith}) async {
    final db = await database;

    await db.rawUpdate(
      'UPDATE fakehadith SET isRead = ? WHERE _id = ?',
      [0, dbFakeHaith.id],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
