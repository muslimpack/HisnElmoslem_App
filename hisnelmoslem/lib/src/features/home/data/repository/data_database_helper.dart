import 'dart:async';
import 'dart:io';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_hadith_read.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_content_favourite.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title_favourite.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDataDBHelper {
  /* ************* Variables ************* */

  static const String dbName = "data.db";
  static const int dbVersion = 1;

  /* ************* Singleton Constructor ************* */

  static UserDataDBHelper? _databaseHelper;
  static Database? _database;

  factory UserDataDBHelper() {
    _databaseHelper ??= UserDataDBHelper._createInstance();
    return _databaseHelper!;
  }

  UserDataDBHelper._createInstance();

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

  /// On create database
  FutureOr<void> _onCreateDatabase(Database db, int version) async {
    hisnPrint("Create data.db");

    /// Create fake_hadith_is_read table
    await db.execute('''
    CREATE TABLE "fake_hadith_is_read" (
      "_id"	INTEGER,
      "hadith_id"	INTEGER UNIQUE,
      "isRead"	INTEGER,
      PRIMARY KEY("_id" AUTOINCREMENT)
    );
    ''');

    /// Create favourite_contents table
    await db.execute('''
    CREATE TABLE "favourite_contents" (
      "_id"	INTEGER,
      "content_id"	INTEGER UNIQUE,
      "favourite"	INTEGER,
      PRIMARY KEY("_id" AUTOINCREMENT)
    );
    ''');

    /// Create favourite_titles table
    await db.execute('''
    CREATE TABLE "favourite_titles" (
      "_id"	INTEGER,
      "title_id"	INTEGER UNIQUE,
      "favourite"	INTEGER,
      PRIMARY KEY("_id" AUTOINCREMENT)
    );
    ''');

    /// default favourite titles
    await db.execute('''
    INSERT INTO favourite_titles (title_id, favourite) VALUES
    (3, 1),     -- أذكار الاستيقاظ من النوم
    (27, 1),    -- السلام بعد الصلاة
    (29, 1),    -- الصباح
    (30, 1),    -- المساء
    (31, 1),    -- النوم
    (96, 1),    -- السفر
    (98, 1),    -- دخول السوق
    (107, 1);   -- فضل السلام على النبي
    ''');
  }

  /// On upgrade database version
  FutureOr<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {}

  /// On downgrade database version
  FutureOr<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {}

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

  Future<bool> isTitleInFavorites({required int titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * from favourite_titles WHERE title_id = ?''',
      [titleId],
    );

    if (maps.isEmpty) return false;

    final DbTitleFavourite dbTitleFavourite = List.generate(maps.length, (i) {
      return DbTitleFavourite.fromMap(maps[i]);
    }).first;

    return dbTitleFavourite.favourite;
  }

  /// Add title to favourite
  Future<void> addTitleToFavourite({required DbTitle dbTitle}) async {
    final db = await database;

    final List<Map<String, dynamic>> existingRecords = await db.query(
      'favourite_titles',
      where: 'title_id = ?',
      whereArgs: [dbTitle.id],
    );

    if (existingRecords.isEmpty) {
      await db.transaction((txn) async {
        await txn.insert('favourite_titles', {
          'title_id': dbTitle.id,
          'favourite': 1, // 1 for true
        });
      });
    } else {
      await db.rawUpdate(
        'UPDATE favourite_titles SET favourite = ? WHERE title_id = ?',
        [1, dbTitle.id],
      );
    }
  }

  /// Remove title from favourite
  Future<void> deleteTitleFromFavourite({required DbTitle dbTitle}) async {
    final db = await database;

    await db.rawUpdate(
      'UPDATE favourite_titles SET favourite = ? WHERE title_id = ?',
      [0, dbTitle.id],
    );
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

  Future<bool> isContentInFavorites({required int contentId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT *  from favourite_contents WHERE content_id = ?''',
      [contentId],
    );
    if (maps.isEmpty) return false;
    final DbContentFavourite dbContentFavourite =
        List.generate(maps.length, (i) {
      return DbContentFavourite.fromMap(maps[i]);
    }).first;

    return dbContentFavourite.favourite;
  }

  /// Add content to favourite
  Future<void> addContentToFavourite({required DbContent dbContent}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> existingRecords = await db.query(
      'favourite_contents',
      where: 'content_id = ?',
      whereArgs: [dbContent.id],
    );

    if (existingRecords.isEmpty) {
      await db.transaction((txn) async {
        await txn.insert('favourite_contents', {
          'content_id': dbContent.id,
          'favourite': 1, // 1 for true
        });
      });
    } else {
      await db.rawUpdate(
        'UPDATE favourite_contents SET favourite = ? WHERE content_id = ?',
        [1, dbContent.id],
      );
    }
  }

  /// Remove Content from favourite
  Future<void> removeContentFromFavourite({
    required DbContent dbContent,
  }) async {
    final Database db = await database;

    await db.rawUpdate(
      'UPDATE favourite_contents SET favourite = ? WHERE content_id = ?',
      [0, dbContent.id],
    );
  }

  /* ************* FakeHadith Read ************* */

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
      [fakeHadithId],
    );
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

  /// Mark hadith as read
  Future<void> markFakeHadithAsRead({required DbFakeHaith dbFakeHaith}) async {
    final db = await database;

    await db.rawUpdate(
      '''
        insert or IGNORE into fake_hadith_is_read (hadith_id , isRead) values (?,?);
        ''',
      [dbFakeHaith.id, 1],
    );
    await db.rawUpdate(
      '''
        UPDATE fake_hadith_is_read SET isRead = ? WHERE hadith_id =?
        ''',
      [1, dbFakeHaith.id],
    );
  }

  /// Mark hadith as unread
  Future<void> markFakeHadithAsUnRead({
    required DbFakeHaith dbFakeHaith,
  }) async {
    final db = await database;

    await db.rawUpdate(
      '''
        insert or IGNORE into fake_hadith_is_read (hadith_id , isRead) values (?,?);
        ''',
      [dbFakeHaith.id, 0],
    );
    await db.rawUpdate(
      '''
        UPDATE fake_hadith_is_read SET isRead = ? WHERE hadith_id =?
        ''',
      [0, dbFakeHaith.id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
