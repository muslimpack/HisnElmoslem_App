import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/verse_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

UthmaniRepository uthmaniRepository = UthmaniRepository();

class UthmaniRepository {
  ///|*| ************* Variables ************* *|

  static const String name = "quran.ar.uthmani.v2";
  static const String dbName = "$name.db";
  static const int dbVersion = 1;

  static UthmaniRepository? _databaseHelper;
  static Database? _database;

  ///|*| ************* Singleton Constructor ************* *|
  factory UthmaniRepository() {
    _databaseHelper ??= UthmaniRepository._createInstance();
    return _databaseHelper!;
  }

  UthmaniRepository._createInstance();

  Future<Database> get database async {
    if (_database == null || !(_database?.isOpen ?? false)) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  ///|*| ************* Database Creation ************* *|

  /// init
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
      if (currentVersion != dbVersion) {
        hisnPrint("[DB] New version detected");
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
    /// Create bookmark table
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

  ///|*| ************* Functions ************* |

  Future<String> getArabicText({
    required int sura,
    required int startAyah,
    required int endAyah,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
SELECT * FROM arabic_text 
WHERE sura = ? AND ayah BETWEEN ? AND ? 
ORDER BY ayah;
''',
      [sura, startAyah, endAyah],
    );

    if (maps.isEmpty) return "";

    return maps.map((e) => Verse.fromMap(e)).fold(
          "",
          (previousValue, element) =>
              "$previousValue ${element.text} ${element.ayah.toArabicNumber()}",
        );
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
