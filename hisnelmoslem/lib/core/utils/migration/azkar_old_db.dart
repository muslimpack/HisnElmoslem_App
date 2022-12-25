import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

AzkarOldDBHelper azkarOldDBHelper = AzkarOldDBHelper();

class AzkarOldDBHelper {
  /* ************* Variables ************* */

  static const String dbName = "hisn_elmoslem_database.db";
  static const int dbVersion = 1;

  /* ************* Singelton Constractor ************* */

  static AzkarOldDBHelper? _databaseHelper;
  static Database? _database;

  AzkarOldDBHelper._createInstance();

  factory AzkarOldDBHelper() {
    _databaseHelper ??= AzkarOldDBHelper._createInstance();
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

  /**
   * Chapters Operations
   */

  /// Get all chapters from database
  Future<List<DbChapter>> getAllChapters() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('chapters');

    return List.generate(maps.length, (i) {
      return DbChapter.fromMap(maps[i]);
    });
  }

  /**
   * Titles Operations
   */

  /// Get all titles
  Future<List<DbTitle>> getAllTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
        titles._id,titles.name,titles.chapter_id
        ,titles.order_id,favourite_titles.favourite
        FROM titles
        INNER JOIN favourite_titles
        on favourite_titles.title_id = titles.order_id
        ''',
    );

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    });
  }

  /// Get all favourite titles
  Future<List<DbTitle>> getAllFavoriteTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
        titles._id,titles.name,titles.chapter_id
        ,titles.order_id,favourite_titles.favourite
        FROM titles
        INNER JOIN favourite_titles
        on favourite_titles.title_id = titles.order_id WHERE favourite = 1
        ''',
    );

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    });
  }

  /// Get title by index
  Future<DbTitle> getTitleById({required int? id}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
          titles._id,titles.name,titles.chapter_id
          ,titles.order_id,favourite_titles.favourite
          FROM titles
          INNER JOIN favourite_titles
          on favourite_titles.title_id = titles.order_id 
          WHERE order_id = ?
          ''',
      [id],
    );

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    }).where((element) => element.id == id).first;
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

  /**
   * Contents Operations
   */

  /// Get all contents
  Future<List<DbContent>> getAllContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
        contents._id ,contents.content ,contents.chapter_id 
        ,contents.title_id ,contents.order_id ,contents.count ,contents.fadl 
        ,contents.source ,favourite_contents.favourite
        FROM contents
        INNER JOIN favourite_contents
        on favourite_contents.content_id = contents.order_id
        ''',
    );

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Get content by title index
  Future<List<DbContent>> getContentsByTitleId({required int? titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
          contents._id ,contents.content ,contents.chapter_id 
          ,contents.title_id ,contents.order_id ,contents.count ,contents.fadl 
          ,contents.source ,favourite_contents.favourite
          FROM contents
          INNER JOIN favourite_contents
          on favourite_contents.content_id = contents._id
          WHERE title_id = ?
          ORDER BY order_id ASC
          ''',
      [titleId],
    );

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Get favourite content
  Future<List<DbContent>> getFavouriteContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT 
          contents._id ,contents.content ,contents.chapter_id 
          ,contents.title_id ,contents.order_id ,contents.count ,contents.fadl 
          ,contents.source ,favourite_contents.favourite
          FROM contents
          INNER JOIN favourite_contents
          on favourite_contents.content_id = contents._id 
          WHERE favourite = 1''',
    );

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Add content to favourite
  addContentToFavourite({required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = true;
    await db.rawUpdate(
        'UPDATE favourite_contents SET favourite = ? WHERE _id = ?',
        [1, dbContent.id]);
  }

  /// Remove Content from favourite
  removeContentFromFavourite({required DbContent dbContent}) async {
    final Database db = await database;
    dbContent.favourite = false;

    await db.rawUpdate(
        'UPDATE favourite_contents SET favourite = ? WHERE _id = ?',
        [0, dbContent.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
