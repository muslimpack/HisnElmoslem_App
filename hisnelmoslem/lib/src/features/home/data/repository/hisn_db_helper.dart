import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite/sqflite.dart';

class HisnDBHelper {
  final UserDataDBHelper userDataDBHelper;
  /* ************* Variables ************* */

  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 6;

  /* ************* Singleton Constructor ************* */

  static HisnDBHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory HisnDBHelper(UserDataDBHelper userDataDBHelper) {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??= HisnDBHelper._createInstance(userDataDBHelper);
    return _databaseHelper!;
  }

  HisnDBHelper._createInstance(this.userDataDBHelper);

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
      '''SELECT * FROM titles ORDER by `order` ASC''',
    );

    final List<DbTitle> titles = [];

    final bookmarkedTitles = await userDataDBHelper.getAllFavoriteTitles();
    final bookmarkedTitlesMap = {
      for (final e in bookmarkedTitles) e.titleId: e.favourite,
    };

    for (int i = 0; i < maps.length; i++) {
      final DbTitle dbTitle = DbTitle.fromMap(maps[i]);

      titles.add(dbTitle.copyWith(favourite: bookmarkedTitlesMap[dbTitle.id]));
    }

    return titles;
  }

  /// Get all favourite titles
  Future<List<DbTitle>> getAllFavoriteTitles() async {
    final List<DbTitle> titles = [];
    final bookmarkedTitles = await userDataDBHelper.getAllFavoriteTitles();

    for (var i = 0; i < bookmarkedTitles.length; i++) {
      final title = await getTitleById(id: bookmarkedTitles[i].titleId);
      titles.add(title);
    }

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
    final bookmarked =
        await userDataDBHelper.isTitleInFavorites(titleId: dbTitle.id);

    return dbTitle.copyWith(favourite: bookmarked);
  }

  /// Add title to favourite
  Future<void> addTitleToFavourite({required DbTitle dbTitle}) async {
    await userDataDBHelper.addTitleToFavourite(dbTitle: dbTitle);
  }

  /// Remove title from favourite
  Future<void> deleteTitleFromFavourite({required DbTitle dbTitle}) async {
    await userDataDBHelper.deleteTitleFromFavourite(dbTitle: dbTitle);
  }

  /**
   * Contents Operations
   */

  /// Get all contents
  Future<List<DbContent>> getAllContents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents ORDER by `order` ASC''',
    );

    final List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      final DbContent dbContent = DbContent.fromMap(maps[i]);
      final bookmarked = await userDataDBHelper.isContentInFavorites(
        contentId: dbContent.id,
      );
      contents.add(dbContent.copyWith(favourite: bookmarked));
    }

    return contents;
  }

  /// Get content by title index
  Future<List<DbContent>> getContentsByTitleId({required int? titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE titleId = ? ORDER by `order` ASC''',
      [titleId],
    );

    final List<DbContent> contents = [];

    for (var i = 0; i < maps.length; i++) {
      final DbContent dbContent = DbContent.fromMap(maps[i]);
      final bookmarked = await userDataDBHelper.isContentInFavorites(
        contentId: dbContent.id,
      );
      contents.add(dbContent.copyWith(favourite: bookmarked));
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
    final bookmarked = await userDataDBHelper.isContentInFavorites(
      contentId: dbContent.id,
    );

    return dbContent.copyWith(favourite: bookmarked);
  }

  /// Get favourite content
  Future<List<DbContent>> getFavouriteContents() async {
    final List<DbContent> contents = [];
    await userDataDBHelper.getFavouriteContents().then((value) async {
      for (var i = 0; i < value.length; i++) {
        await getContentsByContentId(contentId: value[i].contentId)
            .then((title) => contents.add(title));
      }
    });

    return contents;
  }

  /// Add content to favourite
  Future<void> addContentToFavourite({required DbContent dbContent}) async {
    await userDataDBHelper.addContentToFavourite(dbContent: dbContent);
  }

  /// Remove Content from favourite
  Future<void> removeContentFromFavourite({
    required DbContent dbContent,
  }) async {
    await userDataDBHelper.removeContentFromFavourite(
      dbContent: dbContent,
    );
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
