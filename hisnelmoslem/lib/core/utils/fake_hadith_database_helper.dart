import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hisnelmoslem/app/data/models/fake_haith.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/utils/data_database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

FakeHadithDatabaseHelper fakeHadithDatabaseHelper = FakeHadithDatabaseHelper();

class FakeHadithDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "fake_hadith.db";
  static const int dbVersion = 1;

  /* ************* Singelton Constractor ************* */

  static FakeHadithDatabaseHelper? _databaseHelper;
  static Database? _database;

  FakeHadithDatabaseHelper._createInstance();

  factory FakeHadithDatabaseHelper() {
    _databaseHelper ??= FakeHadithDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

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

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  // On create database
  _onCreateDatabase(Database db, int version) async {
    //
  }

  // On upgrade database version
  _onUpgradeDatabase(Database db, int oldVersion, int newVersion) {
    //
  }

  // On downgrade database version
  _onDowngradeDatabase(Database db, int oldVersion, int newVersion) {
    //
  }

  // Copy database from assets to Database Direcorty of app
  _copyFromAssets({required String path}) async {
    //
    try {
      await Directory(dirname(path)).create(recursive: true);

      ByteData data = await rootBundle.load(join("assets", "db", dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      hisnPrint(e.toString());
    }
  }

  /* ************* Functions ************* */

  /// Get all hadith from database
  Future<List<DbFakeHaith>> getAllFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    List<DbFakeHaith> fakeHadiths = [];

    for (var i = 0; i < maps.length; i++) {
      DbFakeHaith fakeHadith = DbFakeHaith.fromMap(maps[i]);
      await dataDatabaseHelper
          .isFakeHadithWereRead(fakeHadithId: fakeHadith.id)
          .then((value) => fakeHadith.isRead = value);
      fakeHadiths.add(fakeHadith);
    }

    return fakeHadiths;
  }

  /// Get fakehadith by id
  Future<DbFakeHaith> getFakeHadithById({required int fakeHadithId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM fakeHadith  WHERE _id = ?''',
      [fakeHadithId],
    );
    DbFakeHaith dbFakeHaith = DbFakeHaith.fromMap(maps[0]);
    await dataDatabaseHelper
        .isFakeHadithWereRead(fakeHadithId: dbFakeHaith.id)
        .then((value) => dbFakeHaith.isRead = value);

    return dbFakeHaith;
  }

  // Get read hadith only
  Future<List<DbFakeHaith>> getReadFakeHadiths() async {
    List<DbFakeHaith> fakeHadiths = [];
    await dataDatabaseHelper.getReadFakeHadiths().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getFakeHadithById(fakeHadithId: value[i].hadithId).then((title) {
          fakeHadiths.add(title);
        });
      }
    });

    return fakeHadiths;
  }

  // Get unread hadith only
  Future<List<DbFakeHaith>> getUnreadFakeHadiths() async {
    List<DbFakeHaith> fakeHadiths = [];
    await dataDatabaseHelper.getUnreadFakeHadiths().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getFakeHadithById(fakeHadithId: value[i].hadithId).then((title) {
          fakeHadiths.add(title);
        });
      }
    });

    return fakeHadiths;
  }

  // Mark haduth as read
  Future<void> markFakeHadithAsRead({required DbFakeHaith dbFakeHaith}) async {
    await dataDatabaseHelper.markFakeHadithAsRead(dbFakeHaith: dbFakeHaith);
  }

  // Mark hadith as unread
  Future<void> markFakeHadithAsUnRead(
      {required DbFakeHaith dbFakeHaith}) async {
    await dataDatabaseHelper.markFakeHadithAsUnRead(dbFakeHaith: dbFakeHaith);
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
