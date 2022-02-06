import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/models/zikr_chapters.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../models/zikr_favourite.dart';

AzkarDatabaseHelper azkarDatabaseHelper = AzkarDatabaseHelper();

class AzkarDatabaseHelper {
  /* ************* Variables ************* */

  static const String DB_NAME = "hisn_elmoslem_book.db";
  static const int DATABASE_VERSION = 1;

  /* ************* Singelton Constractor ************* */

  static AzkarDatabaseHelper? _databaseHelper;
  static Database? _database;

  AzkarDatabaseHelper._createInstance();

  factory AzkarDatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = AzkarDatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  /* ************* Database Creation ************* */

  // init
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);

    final exist = await databaseExists(path);

    //Check if database is already in that Directory
    if (!exist) {
      // Database isn't exist > Create new Database
      await _copyFromAssets(path: path);
    }

    return await openDatabase(
      path,
      version: DATABASE_VERSION,
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

      ByteData data = await rootBundle.load(join("assets", "db", DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ************* Functions ************* */

  // Get all chapters from database
  Future<List<DbChapter>> getAllChapters() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('chapters');

    return List.generate(maps.length, (i) {
      return DbChapter.fromMap(maps[i]);
    });
  }

  // Get all titles
  Future<List<DbTitle>> getAllTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('title');

    return List.generate(maps.length, (i) {
      DbTitle dbTitle = DbTitle.fromMap(maps[i]);

      return dbTitle;
      // return DbTitle.fromMap(maps[i]);
    });
  }

  // Get title by index
  Future<DbTitle> getTitleById({required int? id}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('title');

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    }).where((element) => element.id == id).first;
  }

  // Get all contents
  Future<List<DbContent>> getAllContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('contents');

    debugPrint("Future<List<DbContent>> getAllContents()");
    return List.generate(maps.length, (i) {
      DbContent dbContent = DbContent.fromMap(maps[i]);
      debugPrint(dbContent.favourite.toString());
      return dbContent;
      // return DbContent.fromMap(maps[i]);
    });
  }

  // Get content by title index
  Future<List<DbContent>> getContentsByTitleId({required int? titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('contents');

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    }).where((element) => element.titleId == titleId).toList();
  }

  // Get favourite content
  Future<List<DbContent>> getFavouriteContent() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('contents');

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    }).where((element) => element.favourite).toList();
  }

  // Add content to favourite
  addToFavouriteContent({required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = true;
    await db.rawUpdate(
        'UPDATE contents SET favourite = ? WHERE _id = ?', [1, dbContent.id]);
  }

  // Remove Content from favourite
  removeFromFavouriteContent({required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = false;

    await db.rawUpdate(
        'UPDATE contents SET favourite = ? WHERE _id = ?', [0, dbContent.id]);
  }

  /*
  Get favourite titles
  It supposed to be the correct way to get title to favourite
  but not implemented yet
  */
  Future<List<DbFavourite>> getFavourite() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('favourite');

    return List.generate(maps.length, (i) {
      return DbFavourite.fromMap(maps[i]);
    });
  }

  /* 
  Add title to favourite
  It supposed to be the correct way to add title to favourite
  but not implemented yet 
  */
  Future<void> addToFavourite({required DbTitle dbTitle}) async {
    final db = await database;
    dbTitle.favourite = true;

    await db.rawUpdate(
        'UPDATE title SET favourite = ? WHERE _id = ?', [1, dbTitle.id]);
  }

  /*
  Remove title from favourite by id
  It supposed to be the correct way to remove title to favourite
  but not implemented yet
  */
  Future<void> deleteFromFavourite({required DbTitle dbTitle}) async {
    final db = await database;
    dbTitle.favourite = false;

    await db.rawUpdate(
        'UPDATE title SET favourite = ? WHERE _id = ?', [0, dbTitle.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
