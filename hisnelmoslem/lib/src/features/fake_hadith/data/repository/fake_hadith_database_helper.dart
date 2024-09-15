import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:sqflite/sqflite.dart';

class FakeHadithDatabaseHelper {
  final UserDataDBHelper userDataDBHelper;
  /* ************* Variables ************* */

  static const String dbName = "fake_hadith.db";
  static const int dbVersion = 1;

  /* ************* Singleton Constructor ************* */

  static FakeHadithDatabaseHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory FakeHadithDatabaseHelper(UserDataDBHelper userDataDBHelper) {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??=
        FakeHadithDatabaseHelper._createInstance(userDataDBHelper);
    return _databaseHelper!;
  }

  FakeHadithDatabaseHelper._createInstance(this.userDataDBHelper);

  Future<Database> get database async {
    _database ??= await _dbHelper.initDatabase();
    return _database!;
  }

  /* ************* Database Creation ************* */

  /* ************* Functions ************* */

  /// Get all hadith from database
  Future<List<DbFakeHaith>> getAllFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    final List<DbFakeHaith> fakeHadiths = [];

    for (var i = 0; i < maps.length; i++) {
      final DbFakeHaith fakeHadith = DbFakeHaith.fromMap(maps[i]);
      await userDataDBHelper
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
    final DbFakeHaith dbFakeHaith = DbFakeHaith.fromMap(maps[0]);
    await userDataDBHelper
        .isFakeHadithWereRead(fakeHadithId: dbFakeHaith.id)
        .then((value) => dbFakeHaith.isRead = value);

    return dbFakeHaith;
  }

  // Get read hadith only
  Future<List<DbFakeHaith>> getReadFakeHadiths() async {
    final List<DbFakeHaith> fakeHadiths = [];
    await userDataDBHelper.getReadFakeHadiths().then((value) async {
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
    final List<DbFakeHaith> fakeHadiths = [];
    await userDataDBHelper.getUnreadFakeHadiths().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getFakeHadithById(fakeHadithId: value[i].hadithId).then((title) {
          fakeHadiths.add(title);
        });
      }
    });

    return fakeHadiths;
  }

  // Mark hadith as read
  Future<void> markFakeHadithAsRead({required DbFakeHaith dbFakeHaith}) async {
    await userDataDBHelper.markFakeHadithAsRead(dbFakeHaith: dbFakeHaith);
  }

  // Mark hadith as unread
  Future<void> markFakeHadithAsUnRead({
    required DbFakeHaith dbFakeHaith,
  }) async {
    await userDataDBHelper.markFakeHadithAsUnRead(
      dbFakeHaith: dbFakeHaith,
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
