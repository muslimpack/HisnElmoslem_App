import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/models/fake_haith.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/utils/data_database_helper.dart';
import 'package:hisnelmoslem/utils/migration/azkar_old_db.dart';
import 'package:hisnelmoslem/utils/migration/fake_hadith_old_db.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

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

    //Check if database is already in that Directory
    if (!exist) {
      // Database isn't exist > Create new Database
      await _copyFromAssets(path: path);

      /// Check if hisnelmoslem db is exist or not
      /// If hisn elmoslem not exist that mean the app is in first open
      /// or app data where deleted before
      /// and no need for all code below
      final pathHisn = join(dbPath, "hisn_elmoslem_database.db");
      final existHisn = await databaseExists(pathHisn);
      if (!existHisn) {
        return;
      }

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
      debugPrint(e.toString());
    }
  }

  /// Starting to copy old data to new db
  static Future<void> _copyDataFromCurrentDataDBs() async {
    await _copyDataFromFavoriteContentInHisElmosels();
    await _copyDataFromFavoriteTitlesInHisElmosels();
    await _copyDataFromFakeHadith();
  }

  /// Copy favourite content data
  static Future<void> _copyDataFromFavoriteContentInHisElmosels() async {
    List<DbContent> contents = [];
    await azkarOldDBHelper.getAllContents().then((value) => contents = value);
    contents.map((e) async {
      if (e.favourite) {
        await dataDatabaseHelper.addContentToFavourite(dbContent: e);
      } else {
        await dataDatabaseHelper.removeContentFromFavourite(dbContent: e);
      }
    });
  }

  /// Copy favorite title data
  static Future<void> _copyDataFromFavoriteTitlesInHisElmosels() async {
    List<DbTitle> titles = [];
    await azkarOldDBHelper.getAllTitles().then((value) => titles = value);
    titles.map((e) async {
      if (e.favourite) {
        await dataDatabaseHelper.addTitleToFavourite(dbTitle: e);
      } else {
        await dataDatabaseHelper.deleteTitleFromFavourite(dbTitle: e);
      }
    });
  }

  /// Copy Fake hadith data
  static Future<void> _copyDataFromFakeHadith() async {
    List<DbFakeHaith> titles = [];
    await fakeHadithOldDBHelper
        .getAllFakeHadiths()
        .then((value) => titles = value);
    titles.map((e) async {
      if (e.isRead) {
        await fakeHadithOldDBHelper.markAsRead(dbFakeHaith: e);
      } else {
        await fakeHadithOldDBHelper.markAsUnRead(dbFakeHaith: e);
      }
    });
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
    await databaseFactory.deleteDatabase(path);
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
      debugPrint(e.toString());
    }
  }
}
