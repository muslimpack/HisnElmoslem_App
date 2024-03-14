import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  late final String dbName;
  late final int dbVersion;

  DBHelper({required this.dbName, required this.dbVersion}) {
    hisnPrint("DatabaseHelper for $dbName");
  }

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

  Future<void> copyFromAssets(String path, String dbAssetPath) async {
    hisnPrint("$dbName copying new db...");

    try {
      if (Platform.isWindows) {
        File(dbAssetPath).copy(path);
      } else {
        Directory(dirname(path)).createSync(recursive: true);
        final ByteData data = await rootBundle.load(dbAssetPath);
        final List<int> bytes = data.buffer.asUint8List();
        await File(path).writeAsBytes(bytes, flush: true);
      }
      hisnPrint("$dbName copy done");
    } catch (e) {
      hisnPrint("$dbName copy failed: $e");
    }
  }

  Future<Database> initDatabase() async {
    hisnPrint("$dbName init db");
    final String path = await getDbPath();
    final bool exist = await databaseExists(path);

    if (!exist) {
      await copyFromAssets(path, 'assets/db/$dbName');
    }

    final Database database = await openDatabase(path);

    await database.getVersion().then((currentVersion) async {
      if (currentVersion < dbVersion) {
        hisnPrint("$dbName detect new version");
        database.close();
        await deleteDatabase(path);
        await copyFromAssets(path, 'assets/db/$dbName');
      }
    });

    return openDatabase(path, version: dbVersion);
  }
}
