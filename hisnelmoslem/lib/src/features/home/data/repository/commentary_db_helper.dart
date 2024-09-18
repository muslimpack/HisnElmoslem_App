import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/db_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/commentary.dart';
import 'package:sqflite/sqflite.dart';

class CommentaryDBHelper {
  /* ************* Variables ************* */

  static const String dbName = "commentary.db";
  static const int dbVersion = 1;

  /* ************* Singleton Constructor ************* */

  static CommentaryDBHelper? _databaseHelper;
  static Database? _database;
  static late final DBHelper _dbHelper;

  factory CommentaryDBHelper() {
    _dbHelper = DBHelper(dbName: dbName, dbVersion: dbVersion);
    _databaseHelper ??= CommentaryDBHelper._createInstance();
    return _databaseHelper!;
  }

  CommentaryDBHelper._createInstance();

  Future<Database> get database async {
    _database ??= await _dbHelper.initDatabase();
    return _database!;
  }

  /* ************* Functions ************* */

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
