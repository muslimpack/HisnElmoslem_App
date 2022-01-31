import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/zikr_chapters.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_favourite.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

AzkarDatabaseHelper azkarDatabaseHelper = AzkarDatabaseHelper();

class AzkarDatabaseHelper {
  static AzkarDatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Constant name
  static const String DB_NAME = "hisn_elmoslem_book.db";
  static const int DATABASE_VERSION = 1;

  // Named constructor to create instance of DatabaseHelper
  AzkarDatabaseHelper._createInstance();

  factory AzkarDatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = AzkarDatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    // final dbPath = "storage/emulated/0/hisn_elmoslem/azkar/db/";
    final path = join(dbPath, DB_NAME);

    final exist = await databaseExists(path);

    //Check if database is already in that Directory
    if (exist) {
      // Database is exist > open Database
      await openDatabase(path);
    } else {
      // Database isn't exist > Create new Database

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {}

      ByteData data = await rootBundle.load(join("assets", "db", DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }
    await openDatabase(path);
    return openDatabase(path);
  }

  // A method that retrieves all the chapters from the chapters table.
  Future<List<DbChapter>> getAllChapters() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('chapters');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbChapter(
        id: maps[i]['_id'],
        name: maps[i]['name'],
        orderId: maps[i]['order_id'],
      );
    });
  }

  // A method that retrieves all the chapters from the chapters table.
  Future<List<DbTitle>> getAllTitles() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('title');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbTitle(
        id: maps[i]['_id'],
        name: maps[i]['name'],
        chapterId: maps[i]['chapter_id'],
        orderId: maps[i]['order_id'],
        favourite: maps[i]['favourite'],
        alarm: maps[i]['alarm'],
      );
    });
  }

// A method that retrieves all the chapters from the chapters table.
  Future<DbTitle> getTitleByIndex({required int? index}) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('title');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbTitle(
        id: maps[i]['_id'],
        name: maps[i]['name'],
        chapterId: maps[i]['chapter_id'],
        orderId: maps[i]['order_id'],
        favourite: maps[i]['favourite'],
        alarm: maps[i]['alarm'],
      );
    }).where((element) => element.id == index).first;
  }

  // A method that retrieves all the contents from the contents table.
  Future<List<DbContent>> getAllContents() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The contents.
    final List<Map<String, dynamic>> maps = await db.query('contents');

    // Convert the List<Map<String, dynamic> into a List<contents>.
    return List.generate(maps.length, (i) {
      return DbContent(
        id: maps[i]['_id'],
        content: (maps[i]['content'] as String).replaceAll("\\n", "\n"),
        chapterId: maps[i]['chapter_id'],
        titleId: maps[i]['title_id'],
        orderId: maps[i]['order_id'],
        count: maps[i]['count'],
        fadl: ((maps[i]['fadl'] ?? "") as String).replaceAll("\\n", "\n"),
        source: maps[i]['source'] ?? "",
      );
    });
  }

  // A method that retrieves all the contents from the contents table.
  Future<List<DbContent>> getContentsByTitleIndex({required int? index}) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The contents.
    final List<Map<String, dynamic>> maps = await db.query('contents');

    // Convert the List<Map<String, dynamic> into a List<contents>.
    return List.generate(maps.length, (i) {
      return DbContent(
        id: maps[i]['_id'],
        content: (maps[i]['content'] as String).replaceAll("\\n", "\n"),
        chapterId: maps[i]['chapter_id'],
        titleId: maps[i]['title_id'],
        orderId: maps[i]['order_id'],
        count: maps[i]['count'],
        fadl: ((maps[i]['fadl'] ?? "") as String).replaceAll("\\n", "\n"),
        source: maps[i]['source'] ?? "",
      );
    }).where((element) => element.titleId == index).toList();
  }

  // A method that retrieves all the contents from the favourite table.
  Future<List<DbFavourite>> getFavourite() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The contents.
    final List<Map<String, dynamic>> maps = await db.query('favourite');

    // Convert the List<Map<String, dynamic> into a List<favourite>.
    return List.generate(maps.length, (i) {
      return DbFavourite(
        id: maps[i]['_id'],
        contentId: maps[i]['content_id'],
        orderId: maps[i]['order_id'],
      );
    });
  }

  // Define a function that inserts favourite into the database
  // Future<void> insertZikrFromFavourite(DbFavourite favourite) async {
  //   // Get a reference to the database.
  //   final Database db = await database;
  //
  //   // Insert the favourite into the correct table. You might also specify the
  //   // `conflictAlgorithm` to use in case the same favourite is inserted twice.
  //   //
  //   // In this case, replace any previous data.
  //   await db.insert(
  //     'favourite',
  //     favourite.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<void> addToFavourite({required DbTitle dbTitle}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.update(
      'title',
      DbTitle(
        id: dbTitle.id,
        name: dbTitle.name,
        chapterId: dbTitle.chapterId,
        orderId: dbTitle.orderId,
        favourite: 1,
        alarm: dbTitle.alarm,
      ).toMap(),
      // Use a `where` clause to delete a specific favourite.
      where: "_id = ?",
      // Pass the favourite's id as a whereArg to prevent SQL injection.
      whereArgs: [dbTitle.id],
    );
  }

  Future<void> deleteFromFavourite({required DbTitle dbTitle}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.update(
      'title',
      DbTitle(
        id: dbTitle.id,
        name: dbTitle.name.toString(),
        chapterId: dbTitle.chapterId,
        orderId: dbTitle.orderId,
        favourite: 0,
        alarm: dbTitle.alarm,
      ).toMap(),
      // Use a `where` clause to delete a specific favourite.
      where: "_id = ?",
      // Pass the favourite's id as a whereArg to prevent SQL injection.
      whereArgs: [dbTitle.id],
    );
  }

  Future<void> updateAlarmStatus({required DbTitle dbTitle}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.update(
      'title',
      DbTitle(
        id: dbTitle.id,
        name: dbTitle.name.toString(),
        chapterId: dbTitle.chapterId,
        orderId: dbTitle.orderId,
        favourite: dbTitle.favourite,
        alarm: dbTitle.alarm,
      ).toMap(),
      // Use a `where` clause to delete a specific favourite.
      where: "_id = ?",
      // Pass the favourite's id as a whereArg to prevent SQL injection.
      whereArgs: [dbTitle.id],
    );
  }

// Future<void> deleteZikrFromFavourite(int id) async {
//   // Get a reference to the database.
//   final db = await database;
//
//   // Remove the favourite from the Database.
//   await db.delete(
//     'favourite',
//     // Use a `where` clause to delete a specific favourite.
//     where: "_id = ?",
//     // Pass the favourite's id as a whereArg to prevent SQL injection.
//     whereArgs: [id],
//   );
// }
  Future close() async {
    final db = await database;
    db.close();
  }
}
