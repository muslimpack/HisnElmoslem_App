import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/core/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/core/utils/migration/azkar_old_db.dart';
import 'package:hisnelmoslem/core/utils/migration/fake_hadith_old_db.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Migration {
  /* ************* Database Creation ************* */

  static Future<void> start() async {
    await initDataDatabase();
  }

  /// init
  static Future<void> initDataDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "data.db");
    final exist = await databaseExists(path);

    ///
    final pathHisn = join(dbPath, "hisn_elmoslem_database.db");
    final existHisn = await databaseExists(pathHisn);

    //Check if database is already in that Directory
    if (!exist || existHisn) {
      // Database isn't exist > Create new Database
      await _copyFromAssets(path: path);

      /// Start Copying data from current databases
      await _copyDataFromCurrentDataDBs();

      /// Delete old DBS
      await deleteOldDBs();

      /// Copy New DBS
      await copyNewDBS();
    } else {
      return;
    }
  }

  /// Copy database from assets to Database Direcorty of app
  static Future<void> _copyFromAssets({required String path}) async {
    //
    try {
      await Directory(dirname(path)).create(recursive: true);

      ByteData data = await rootBundle.load(join("assets", "db", "data.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      hisnPrint(e.toString());
    }
  }

  /// Starting to copy old data to new db
  static Future<void> _copyDataFromCurrentDataDBs() async {
    await _copyDataFromFavoriteTitlesInHisElmosels();
    await _copyDataFromFavoriteContentInHisElmosels();
    await _copyDataFromFakeHadith();
  }

  /// Copy favourite content data
  static Future<void> _copyDataFromFavoriteContentInHisElmosels() async {
    ///
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "hisn_elmoslem_database.db");
    final exist = await databaseExists(path);
    if (!exist) {
      return;
    }

    ///
    try {
      List<DbContent> contents = [];
      await azkarOldDBHelper
          .getFavouriteContents()
          .then((value) => contents.addAll(value));

      for (var i = 0; i < contents.length; i++) {
        await azkarDatabaseHelper.addContentToFavourite(dbContent: contents[i]);
      }
    } catch (e) {
      hisnPrint("content error: $e");
    }
  }

  /// Copy favorite title data
  static Future<void> _copyDataFromFavoriteTitlesInHisElmosels() async {
    ///
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "hisn_elmoslem_database.db");
    final exist = await databaseExists(path);
    if (!exist) {
      return;
    }
    try {
      ///
      List<DbTitle> titles = [];
      await azkarOldDBHelper
          .getAllFavoriteTitles()
          .then((value) => titles.addAll(value));

      for (var i = 0; i < titles.length; i++) {
        await azkarDatabaseHelper.addTitleToFavourite(dbTitle: titles[i]);
      }
    } catch (e) {
      hisnPrint("Title error: $e");
    }
  }

  /// Copy Fake hadith data
  static Future<void> _copyDataFromFakeHadith() async {
    ///
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "fake_hadith.db");
    final exist = await databaseExists(path);
    if (!exist) {
      return;
    }

    ///
    try {
      List<DbFakeHaith> fakeHadiths = [];
      await fakeHadithOldDBHelper
          .getAllFakeHadiths()
          .then((value) => fakeHadiths.addAll(value));

      for (var i = 0; i < fakeHadiths.length; i++) {
        if (fakeHadiths[i].isRead) {
          await fakeHadithDatabaseHelper.markFakeHadithAsRead(
            dbFakeHaith: fakeHadiths[i],
          );
        } else {
          await fakeHadithDatabaseHelper.markFakeHadithAsUnRead(
            dbFakeHaith: fakeHadiths[i],
          );
        }
      }
    } catch (e) {
      hisnPrint("FakeHadith error: $e");
    }
  }

  /// Deleting DB from databases path
  static deleteOldDBs() async {
    await deleteFromDBPath(dbName: "hisn_elmoslem_database.db");
    await deleteFromDBPath(dbName: "fake_hadith_database.db");
  }

  /// Delete database from databases path
  static Future<void> deleteFromDBPath({required String dbName}) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    try {
      await databaseFactory.deleteDatabase(path);
    } catch (e) {
      hisnPrint(e.toString());
    }
  }

  /// Copying new databases
  static Future<void> copyNewDBS() async {
    await copyFromAsset(dbName: "hisn_elmoslem.db");
    await copyFromAsset(dbName: "fake_hadith.db");
  }

  /// Copy DB from assets to databases path
  static Future<void> copyFromAsset({required String dbName}) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    try {
      await Directory(dirname(path)).create(recursive: true);

      ByteData data = await rootBundle.load(join("assets", "db", dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      hisnPrint(e.toString());
    }
  }
}
