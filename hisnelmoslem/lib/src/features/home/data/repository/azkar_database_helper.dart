import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/commentary.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite/sqflite.dart';

AzkarDatabaseHelper azkarDatabaseHelper = AzkarDatabaseHelper();

class AzkarDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 5;

  /* ************* Singleton Constructor ************* */

  static AzkarDatabaseHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory AzkarDatabaseHelper() {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??= AzkarDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  AzkarDatabaseHelper._createInstance();

  Future<Database> get database async {
    _database ??= await _dbHelper.initDatabase();
    return _database!;
  }

  /* ************* Functions ************* */

  /**
   * Titles Operations
   */

  /// Get all titles
  Future<List<DbTitle>> getAllTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM titles ORDER by orderId ASC''',
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
      '''SELECT * FROM titles  WHERE id = ?''',
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
      '''SELECT * FROM contents ORDER by orderId ASC''',
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
      '''SELECT * FROM contents  WHERE titleId = ? ORDER by orderId ASC''',
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
      '''SELECT * FROM contents  WHERE id = ?''',
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
      '''SELECT * FROM commentary  WHERE contentId = ?''',
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
