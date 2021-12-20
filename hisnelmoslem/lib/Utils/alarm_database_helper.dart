import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/AlarmsDb/DbAlarm.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

AlarmDatabaseHelper alarmDatabaseHelper = AlarmDatabaseHelper();

class AlarmDatabaseHelper {
   static  AlarmDatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
   static  Database? _database; // Singleton Database

  // Constant name
  static const String DB_NAME = "alarms.db";
  static const int DATABASE_VERSION = 1;

  // Named constructor to create instance of DatabaseHelper
  AlarmDatabaseHelper._createInstance();

  factory AlarmDatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = AlarmDatabaseHelper
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
  Future<List<DbAlarm>> getAlarms() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The chapters.
    final List<Map<String, dynamic>> maps = await db.query('Alarms');

    // Convert the List<Map<String, dynamic> into a List<chapters>.
    return List.generate(maps.length, (i) {
      return DbAlarm(
        id: maps[i]['id'],
        title: maps[i]['title'],
        body: maps[i]['body'],
        repeatType: maps[i]['repeatType'],
        hour: maps[i]['hour'],
        minute: maps[i]['minute'],
        isActive: maps[i]['isActive'],
      );
    });
  }

  Future<void> addNewAlarm({required DbAlarm dbAlarm}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.insert(
      'Alarms',
      DbAlarm(
        id: dbAlarm.id,
        title: dbAlarm.title,
        body: dbAlarm.body,
        repeatType:dbAlarm.repeatType,
        hour: dbAlarm.hour,
        minute: dbAlarm.minute,
        isActive: dbAlarm.isActive,
      ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAlarmInfo({required DbAlarm dbAlarm}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.update(
      'Alarms',
      DbAlarm(
        id: dbAlarm.id,
        title: dbAlarm.title,
        body: dbAlarm.body,
        repeatType:dbAlarm.repeatType,
        hour: dbAlarm.hour,
        minute: dbAlarm.minute,
        isActive: dbAlarm.isActive,
      ).toMap(),
      // Use a `where` clause to delete a specific favourite.
      where: "id = ?",
      // Pass the favourite's id as a whereArg to prevent SQL injection.
      whereArgs: [dbAlarm.id],

    );
  }

  Future<void> deleteAlarm({required DbAlarm dbAlarm}) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the favourite from the Database.
    await db.delete(
      'alarms',
      // Use a `where` clause to delete a specific favourite.
      where: "id = ?",
      // Pass the favourite's id as a whereArg to prevent SQL injection.
      whereArgs: [dbAlarm.id],
    );
  }


  Future close() async {
    final db = await database;
    db.close();
  }
}
