import 'dart:async';
import 'dart:io';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AlarmDatabaseHelper {
  /* ************* Variables ************* */

  static const String dbName = "alarms_database.db";
  static const int dbVersion = 1;

  static AlarmDatabaseHelper? _databaseHelper;
  static Database? _database;

  /* ************* Singleton Constructor ************* */

  factory AlarmDatabaseHelper() {
    _databaseHelper ??= AlarmDatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  AlarmDatabaseHelper._createInstance();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /* ************* Database Creation ************* */
  Future<String> getDbPath() async {
    late final String path;

    if (Platform.isWindows) {
      final dbPath = (await getApplicationSupportDirectory()).path;
      path = join(dbPath, dbName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }

    return path;
  }

  // init
  Future<Database> _initDatabase() async {
    final path = await getDbPath();
    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  // On create database
  Future<void> _onCreateDatabase(Database db, int version) async {
    hisnPrint("Create alarm.db");

    /// Create alarms table
    await db.execute('''
    CREATE TABLE "alarms" (
      "id"	INTEGER NOT NULL,
      "titleId"	INTEGER NOT NULL UNIQUE,
      "title"	TEXT NOT NULL,
      "body"	TEXT,
      "repeatType"	TEXT,
      "hour"	INTEGER,
      "minute"	INTEGER,
      "isActive"	INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');
  }

  // On upgrade database version
  Future<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  // On downgrade database version
  Future<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  /* ************* Functions ************* */

  /// Get all alarms from database
  Future<List<DbAlarm>> getAlarms() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('alarms');

    return List.generate(maps.length, (i) {
      return DbAlarm.fromMap(maps[i]);
    });
  }

  /// Get alarm by zikr title from database
  Future<DbAlarm> getAlarmByZikrTitle({required DbTitle dbTitle}) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'select * from alarms where title = ?',
      [dbTitle.name],
    );

    if (maps.isNotEmpty) {
      final DbAlarm dbAlarm = DbAlarm.fromMap(maps[0]);

      return dbAlarm;
    } else {
      final DbAlarm tempAlarm = DbAlarm(
        titleId: dbTitle.id,
        title: dbTitle.name,
      );
      return tempAlarm;
    }
  }

  // Add new alarm to database
  Future<int> addNewAlarm({required DbAlarm dbAlarm}) async {
    final db = await database;

    return db.insert(
      'alarms',
      dbAlarm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update alarm by ID
  Future<void> updateAlarmInfo({required DbAlarm dbAlarm}) async {
    final db = await database;

    await db.update(
      'alarms',
      dbAlarm.toMap(),
      where: "titleId = ?",
      whereArgs: [dbAlarm.titleId],
    );
  }

  // Delete alarm by ID
  Future<void> deleteAlarm({required DbAlarm dbAlarm}) async {
    final db = await database;

    await db.delete(
      'alarms',
      where: "titleId = ?",
      whereArgs: [dbAlarm.titleId],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
