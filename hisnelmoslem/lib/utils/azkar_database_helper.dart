import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/zikr_chapters.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/functions/print.dart';
import 'package:hisnelmoslem/utils/data_database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

AzkarDatabaseHelper azkarDatabaseHelper = AzkarDatabaseHelper();

class AzkarDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 1;

  /* ************* Singelton Constractor ************* */

  static AzkarDatabaseHelper? _databaseHelper;
  static Database? _database;

  AzkarDatabaseHelper._createInstance();

  factory AzkarDatabaseHelper() {
    _databaseHelper ??= AzkarDatabaseHelper._createInstance();
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
      '''SELECT * FROM titles''',
    );

    List<DbTitle> titles = [];

    for (int i = 0; i < maps.length; i++) {
      DbTitle dbTitle = DbTitle.fromMap(maps[i]);
      await dataDatabaseHelper
          .isTitleInFavourites(titleId: dbTitle.id)
          .then((value) {
        dbTitle.favourite = value;
      });

      titles.add(dbTitle);
    }

    return titles;
  }

  /// Get all favourite titles
  Future<List<DbTitle>> getAllFavoriteTitles() async {
    List<DbTitle> titles = [];
    await dataDatabaseHelper.getAllFavoriteTitles().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getTitleById(id: value[i].titleId).then((title) {
          titles.add(title);
        });
      }
    });

    return titles;
  }

  /// Get title by index
  Future<DbTitle> getTitleById({required int? id}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM titles  WHERE order_id = ?''',
      [id],
    );
    DbTitle dbTitle = DbTitle.fromMap(maps[0]);
    await dataDatabaseHelper
        .isTitleInFavourites(titleId: dbTitle.id)
        .then((value) => dbTitle.favourite = value);

    return dbTitle;
  }

  /// Add title to favourite
  Future<void> addTitleToFavourite({required DbTitle dbTitle}) async {
    await dataDatabaseHelper.addTitleToFavourite(dbTitle: dbTitle);
  }

  /// Remove title from favourite
  Future<void> deleteTitleFromFavourite({required DbTitle dbTitle}) async {
    await dataDatabaseHelper.deleteTitleFromFavourite(dbTitle: dbTitle);
  }

  /**
   * Contents Operations
   */

  /// Get all contents
  Future<List<DbContent>> getAllContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents''',
    );

    List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      DbContent dbContent = DbContent.fromMap(maps[i]);
      await dataDatabaseHelper
          .isContentInFavourites(contentId: dbContent.id)
          .then((value) => dbContent.favourite = value);
      contents.add(dbContent);
    }

    return contents;
  }

  /// Get content by title index
  Future<List<DbContent>> getContentsByTitleId({required int? titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE title_id = ? ORDER by order_id ASC''',
      [titleId],
    );

    List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      DbContent dbContent = DbContent.fromMap(maps[i]);
      await dataDatabaseHelper
          .isContentInFavourites(contentId: dbContent.id)
          .then((value) => dbContent.favourite = value);
      contents.add(dbContent);
    }
    return contents;
  }

  /// Get content by title index
  Future<DbContent> getContentsByContentId({
    required int? contentId,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE _id = ?''',
      [contentId],
    );
    DbContent dbContent = DbContent.fromMap(maps[0]);
    await dataDatabaseHelper
        .isContentInFavourites(contentId: dbContent.id)
        .then((value) => dbContent.favourite = value);

    return dbContent;
  }

  /// Get favourite content
  Future<List<DbContent>> getFavouriteContents() async {
    List<DbContent> contents = [];
    await dataDatabaseHelper.getFavouriteContents().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getContentsByContentId(contentId: value[i].contentId)
            .then((title) => contents.add(title));
      }
    });

    return contents;
  }

  /// Add content to favourite
  addContentToFavourite({required DbContent dbContent}) async {
    await dataDatabaseHelper.addContentToFavourite(dbContent: dbContent);
  }

  /// Remove Content from favourite
  removeContentFromFavourite({required DbContent dbContent}) async {
    await dataDatabaseHelper.removeContentFromFavourite(dbContent: dbContent);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
