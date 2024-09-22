import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:sqflite/sqflite.dart';

class FakeHadithDBHelper {
  final UserDataDBHelper userDataDBHelper;
  /* ************* Variables ************* */

  static const String dbName = "fake_hadith.db";
  static const int dbVersion = 2;

  /* ************* Singleton Constructor ************* */

  static FakeHadithDBHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory FakeHadithDBHelper(UserDataDBHelper userDataDBHelper) {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??= FakeHadithDBHelper._createInstance(userDataDBHelper);
    return _databaseHelper!;
  }

  FakeHadithDBHelper._createInstance(this.userDataDBHelper);

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

    final readData = await userDataDBHelper.getReadFakeHadiths();
    final mappedReadData = {for (final e in readData) e.itemId: e.bookmarked};

    return maps.map((e) {
      final fakeHadith = DbFakeHaith.fromMap(e);
      return fakeHadith.copyWith(isRead: mappedReadData[fakeHadith.id]);
    }).toList();
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
