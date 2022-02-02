import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/fakeHaith.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

FakeHadithDatabaseHelper fakeHadithDatabaseHelper = FakeHadithDatabaseHelper();

class FakeHadithDatabaseHelper {
  static FakeHadithDatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  // Constant name
  static const String DB_NAME = "fakeHadith.db";
  static const int DATABASE_VERSION = 1;

  // Named constructor to create instance of DatabaseHelper
  FakeHadithDatabaseHelper._createInstance();

  factory FakeHadithDatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = FakeHadithDatabaseHelper
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
  Future<List<DbFakeHaith>> getAllFakeHadiths() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbFakeHaith(
        id: maps[i]['_id'],
        text: (maps[i]['text'] as String).replaceAll("\\n", "\n"),
        darga: (maps[i]['darga'] as String).replaceAll("\\n", "\n"),
        source: maps[i]['source'],
        isRead: maps[i]['isRead'],
      );
    });
  }

  Future<List<DbFakeHaith>> getReadFakeHadiths() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbFakeHaith(
        id: maps[i]['_id'],
        text: (maps[i]['text'] as String).replaceAll("\\n", "\n"),
        darga: (maps[i]['darga'] as String).replaceAll("\\n", "\n"),
        source: maps[i]['source'],
        isRead: maps[i]['isRead'],
      );
    }).where((element) => element.isRead == 1).toList();
  }

  Future<List<DbFakeHaith>> getUnreadFakeHadiths() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('fakehadith');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbFakeHaith(
        id: maps[i]['_id'],
        source: maps[i]['source'],
        text: (maps[i]['text'] as String).replaceAll("\\n", "\n"),
        darga: (maps[i]['darga'] as String).replaceAll("\\n", "\n"),
        isRead: maps[i]['isRead'],
      );
    }).where((element) => element.isRead == 0).toList();
  }

  Future<void> markAsRead({required DbFakeHaith dbFakeHaith}) async {
    // Get a reference to the database.
    final db = await database;

    // Add the favourite from the Database.
    await db.rawUpdate(
        'UPDATE fakehadith SET isRead = ? WHERE _id = ?', [1, dbFakeHaith.id]);
  }

  Future<void> markAsUnRead({required DbFakeHaith dbFakeHaith}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.rawUpdate(
        'UPDATE fakehadith SET isRead = ? WHERE _id = ?', [0, dbFakeHaith.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
