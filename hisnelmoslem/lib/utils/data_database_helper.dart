import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/fake_hadith_read.dart';
import 'package:hisnelmoslem/models/fake_haith.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_content_favourite.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/models/zikr_title_favourite.dart';
import 'package:hisnelmoslem/shared/functions/print.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

DataDatabaseHelper dataDatabaseHelper = DataDatabaseHelper();

class DataDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "data.db";
  static const int dbVersion = 1;

  /* ************* Singelton Constractor ************* */

  static DataDatabaseHelper? _databaseHelper;
  static Database? _database;

  DataDatabaseHelper._createInstance();

  factory DataDatabaseHelper() {
    _databaseHelper ??= DataDatabaseHelper._createInstance();
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

  /// On create database
  _onCreateDatabase(Database db, int version) async {
    //
  }

  /// On upgrade database version
  _onUpgradeDatabase(Database db, int oldVersion, int newVersion) {
    //
  }

  /// On downgrade database version
  _onDowngradeDatabase(Database db, int oldVersion, int newVersion) {
    //
  }

  /// Copy database from assets to Database Direcorty of app
  Future<void> _copyFromAssets({required String path}) async {
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

  /* ************* HisnElmoslem Titles ************* */

  /// Get all favourite titles
  Future<List<DbTitleFavourite>> getAllFavoriteTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * from favourite_titles WHERE favourite = 1 order by title_id asc''',
    );

    return List.generate(maps.length, (i) {
      return DbTitleFavourite.fromMap(maps[i]);
    });
  }

  Future<bool> isTitleInFavourites({required int titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT * from favourite_titles WHERE title_id = ?''', [titleId]);

    DbTitleFavourite dbTitleFavourite = List.generate(maps.length, (i) {
      return DbTitleFavourite.fromMap(maps[i]);
    }).first;

    return dbTitleFavourite.favourite;
  }

  /// Add title to favourite
  Future<void> addTitleToFavourite({required DbTitle dbTitle}) async {
    final db = await database;
    dbTitle.favourite = true;

    await db.rawUpdate(
        'UPDATE favourite_titles SET favourite = ? WHERE title_id = ?',
        [1, dbTitle.id]);
  }

  /// Remove title from favourite
  Future<void> deleteTitleFromFavourite({required DbTitle dbTitle}) async {
    final db = await database;
    dbTitle.favourite = false;

    await db.rawUpdate(
        'UPDATE favourite_titles SET favourite = ? WHERE title_id = ?',
        [0, dbTitle.id]);
  }

  /* ************* HisnElmoslem Contents ************* */

  /// Get favourite content
  Future<List<DbContentFavourite>> getFavouriteContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * from favourite_contents WHERE favourite = 1''',
    );

    return List.generate(maps.length, (i) {
      return DbContentFavourite.fromMap(maps[i]);
    });
  }

  Future<bool> isContentInFavourites({required int contentId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT *  from favourite_contents WHERE content_id = ?''',
        [contentId]);

    DbContentFavourite dbContentFavourite = List.generate(maps.length, (i) {
      return DbContentFavourite.fromMap(maps[i]);
    }).first;

    return dbContentFavourite.favourite;
  }

  /// Add content to favourite
  Future<void> addContentToFavourite({required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = true;
    await db.rawUpdate(
        'UPDATE favourite_contents SET favourite = ? WHERE content_id = ?',
        [1, dbContent.id]);
  }

  /// Remove Content from favourite
  Future<void> removeContentFromFavourite(
      {required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = false;

    await db.rawUpdate(
        'UPDATE favourite_contents SET favourite = ? WHERE content_id = ?',
        [0, dbContent.id]);
  }

  /* ************* FakeHaidth Read ************* */

  /// Get read hadith only
  Future<List<DbFakeHadithRead>> getReadFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''Select * from fake_hadith_is_read where isRead = 1''');

    return List.generate(maps.length, (i) {
      return DbFakeHadithRead.fromMap(maps[i]);
    });
  }

  /// Get unread hadith only
  Future<List<DbFakeHadithRead>> getUnreadFakeHadiths() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .rawQuery('''Select * from fake_hadith_is_read where isRead = 0''');

    return List.generate(maps.length, (i) {
      return DbFakeHadithRead.fromMap(maps[i]);
    });
  }

  ///
  Future<bool> isFakeHadithWereRead({required int fakeHadithId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT *  from fake_hadith_is_read WHERE hadith_id = ?''',
        [fakeHadithId]);
    DbFakeHadithRead dbFakeHadithRead;
    if (maps.isNotEmpty) {
      dbFakeHadithRead = List.generate(maps.length, (i) {
        return DbFakeHadithRead.fromMap(maps[i]);
      }).first;
      return dbFakeHadithRead.isRead;
    } else {
      return false;
    }
  }

  /// Mark haduth as read
  Future<void> markFakeHadithAsRead({required DbFakeHaith dbFakeHaith}) async {
    final db = await database;

    await db.rawUpdate('''
        insert or IGNORE into fake_hadith_is_read (hadith_id , isRead) values (?,?);
        ''', [dbFakeHaith.id, 1]);
    await db.rawUpdate('''
        UPDATE fake_hadith_is_read SET isRead = ? WHERE hadith_id =?
        ''', [1, dbFakeHaith.id]);
  }

  /// Mark hadith as unread
  Future<void> markFakeHadithAsUnRead(
      {required DbFakeHaith dbFakeHaith}) async {
    final db = await database;

    await db.rawUpdate('''
        insert or IGNORE into fake_hadith_is_read (hadith_id , isRead) values (?,?);
        ''', [dbFakeHaith.id, 0]);
    await db.rawUpdate('''
        UPDATE fake_hadith_is_read SET isRead = ? WHERE hadith_id =?
        ''', [0, dbFakeHaith.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
