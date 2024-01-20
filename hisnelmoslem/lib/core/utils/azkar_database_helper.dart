import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/utils/data_database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

AzkarDatabaseHelper azkarDatabaseHelper = AzkarDatabaseHelper();

class AzkarDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 3;

  /* ************* Singleton Constructor ************* */

  static AzkarDatabaseHelper? _databaseHelper;
  static Database? _database;

  factory AzkarDatabaseHelper() {
    _databaseHelper ??= AzkarDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  AzkarDatabaseHelper._createInstance();

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

    Database database = await openDatabase(path);

    await database.getVersion().then((currentVersion) async {
      if (currentVersion < dbVersion) {
        database.close();

        //delete the old database so you can copy the new one
        await deleteDatabase(path);

        // Database isn't exist > Create new Database
        await _copyFromAssets(path: path);
      }
    });

    return database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  /// On create database
  FutureOr<void> _onCreateDatabase(Database db, int version) async {
    //
  }

  /// On upgrade database version
  FutureOr<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {
    //
  }

  /// On downgrade database version
  FutureOr<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) {
    //
  }

  /// Copy database from assets to Database Directory of app
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

    final List<DbTitle> titles = [];

    for (int i = 0; i < maps.length; i++) {
      final DbTitle dbTitle = DbTitle.fromMap(maps[i]);
      await dataDatabaseHelper
          .isTitleInFavorites(titleId: dbTitle.id)
          .then((value) {
        dbTitle.favourite = value;
      });

      titles.add(dbTitle);
    }

    return titles;
  }

  /// Get all favourite titles
  Future<List<DbTitle>> getAllFavoriteTitles() async {
    final List<DbTitle> titles = [];
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
    final DbTitle dbTitle = DbTitle.fromMap(maps[0]);
    await dataDatabaseHelper
        .isTitleInFavorites(titleId: dbTitle.id)
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

    final List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      final DbContent dbContent = DbContent.fromMap(maps[i]);
      await dataDatabaseHelper
          .isContentInFavorites(contentId: dbContent.id)
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

    final List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      final DbContent dbContent = DbContent.fromMap(maps[i]);
      await dataDatabaseHelper
          .isContentInFavorites(contentId: dbContent.id)
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
    final DbContent dbContent = DbContent.fromMap(maps[0]);
    await dataDatabaseHelper
        .isContentInFavorites(contentId: dbContent.id)
        .then((value) => dbContent.favourite = value);

    return dbContent;
  }

  /// Get favourite content
  Future<List<DbContent>> getFavouriteContents() async {
    final List<DbContent> contents = [];
    await dataDatabaseHelper.getFavouriteContents().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getContentsByContentId(contentId: value[i].contentId)
            .then((title) => contents.add(title));
      }
    });

    return contents;
  }

  /// Add content to favourite
  Future<void> addContentToFavourite({required DbContent dbContent}) async {
    await dataDatabaseHelper.addContentToFavourite(dbContent: dbContent);
  }

  /// Remove Content from favourite
  Future<void> removeContentFromFavourite({
    required DbContent dbContent,
  }) async {
    await dataDatabaseHelper.removeContentFromFavourite(dbContent: dbContent);
  }

  // ************************************************
  // Commentary

  /// Get Commentary by contentId
  Future<Commentary> getCommentaryByContentId({
    required int? contentId,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM commentary  WHERE content_id = ?''',
      [contentId],
    );
    final Commentary commentary = Commentary.fromMap(maps[0]);
    return commentary;
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
