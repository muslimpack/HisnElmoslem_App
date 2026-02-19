import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/sql_query.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite/sqflite.dart';

class HisnDBHelper {
  static const String dbName = "hisn_elmoslem.db";
  static const int dbVersion = 8;

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

  ///MARK: New Search

  SqlQuery _searchTitlesSearchType(
    String searchText,
    String property, {
    required SearchType searchType,
    required bool useFilters,
  }) {
    final SqlQuery sqlQuery = SqlQuery();

    final List<String> splittedSearchWords = searchText.trim().split(' ');

    switch (searchType) {
      case SearchType.typical:
        sqlQuery.query = 'WHERE $property LIKE ?';
        sqlQuery.args.addAll(['%$searchText%']);

      case SearchType.allWords:
        final String allWordsQuery = splittedSearchWords
            .map((word) => '$property LIKE ?')
            .join(' AND ');
        final List<String> params = splittedSearchWords.map((word) => '%$word%').toList();
        sqlQuery.query = 'WHERE ($allWordsQuery)';
        sqlQuery.args.addAll([...params]);

      case SearchType.anyWords:
        final String allWordsQuery = splittedSearchWords
            .map((word) => '$property LIKE ?')
            .join(' OR ');
        final List<String> params = splittedSearchWords.map((word) => '%$word%').toList();
        sqlQuery.query = 'WHERE ($allWordsQuery)';
        sqlQuery.args.addAll([...params]);
    }

    return sqlQuery;
  }

  Future<(int, List<DbTitle>)> searchTitleByName({
    required String searchText,
    required SearchType searchType,
    required int limit,
    required int offset,
  }) async {
    if (searchText.isEmpty) return (0, <DbTitle>[]);

    final Database db = await database;

    final whereFilters = _searchTitlesSearchType(
      searchText,
      "search",
      searchType: searchType,
      useFilters: true,
    );

    /// Pagination
    final String qurey =
        '''SELECT * FROM titles ${whereFilters.query} ORDER BY `id` LIMIT ? OFFSET ?''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(qurey, [
      ...whereFilters.args,
      limit,
      offset,
    ]);

    /// Total Count
    final String totalCountQurey =
        '''SELECT COUNT(*) as count FROM titles ${whereFilters.query} ''';
    final List<Map<String, dynamic>> countResult = await db.rawQuery(totalCountQurey, [
      ...whereFilters.args,
    ]);
    final int count = countResult.first["count"] as int? ?? 0;

    final itemList = List.generate(maps.length, (i) {
      return DbTitle.fromMap(maps[i]);
    });

    return (count, itemList);
  }

  Future<(int, List<DbContent>)> searchContent({
    required String searchText,
    required SearchType searchType,
    required int limit,
    required int offset,
  }) async {
    if (searchText.isEmpty) return (0, <DbContent>[]);

    final Database db = await database;

    final whereFilters = _searchTitlesSearchType(
      searchText,
      "search",
      searchType: searchType,
      useFilters: true,
    );

    /// Pagination
    final String qurey =
        '''SELECT * FROM contents ${whereFilters.query} ORDER BY `order` LIMIT ? OFFSET ?''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(qurey, [
      ...whereFilters.args,
      limit,
      offset,
    ]);

    /// Total Count
    final String totalCountQurey =
        '''SELECT COUNT(*) as count FROM contents ${whereFilters.query} ''';
    final List<Map<String, dynamic>> countResult = await db.rawQuery(totalCountQurey, [
      ...whereFilters.args,
    ]);
    final int count = countResult.first["count"] as int? ?? 0;

    final itemList = List.generate(maps.length, (i) {
      return DbContent.fromMap(maps[i]);
    });

    return (count, itemList);
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
