import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite/sqflite.dart';

class HisnDBHelper {
  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 6;

  /* ************* Singleton Constructor ************* */

  static HisnDBHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory HisnDBHelper() {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??= HisnDBHelper._createInstance();
    return _databaseHelper!;
  }

  HisnDBHelper._createInstance();

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

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    });
  }

  /// Get title by index
  Future<DbTitle> getTitleById({required int? id}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM titles  WHERE id = ?''',
      [id],
    );
    return DbTitle.fromMap(maps.first);
  }

  /// get list of titles by ids
  Future<List<DbTitle>> getTitlesByIds({required List<int> ids}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM titles  WHERE id IN (${ids.join(",")})''',
    );

    return List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    });
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
    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Get content by title index
  Future<List<DbContent>> getContentsByTitleId({required int? titleId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE titleId = ? ORDER by `order` ASC''',
      [titleId],
    );

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Get content by title index
  Future<DbContent> getContentsByContentId({required int? contentId}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE id = ?''',
      [contentId],
    );
    final DbContent dbContent = DbContent.fromMap(maps[0]);

    return dbContent;
  }

  /// get list of contents by ids
  Future<List<DbContent>> getContentsByIds({required List<int> ids}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT * FROM contents  WHERE id IN (${ids.join(",")})''',
    );

    return List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
