import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/repository/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class BackupRestoreRepo {
  final UserDataDBHelper userDataDBHelper;
  final TallyDatabaseHelper tallyDatabaseHelper;
  final AlarmDatabaseHelper alarmDatabaseHelper;
  final FakeHadithDBHelper fakeHadithDBHelper;

  BackupRestoreRepo({
    required this.userDataDBHelper,
    required this.tallyDatabaseHelper,
    required this.alarmDatabaseHelper,
    required this.fakeHadithDBHelper,
  });

  Future<List<String>> _getDbPaths() async {
    final List<String> paths = [];
    paths.add(await userDataDBHelper.getDbPath());
    paths.add(await tallyDatabaseHelper.getDbPath());
    paths.add(await alarmDatabaseHelper.getDbPath());

    late final String fakeHadithPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final dbPath = (await getApplicationSupportDirectory()).path;
      fakeHadithPath = join(dbPath, FakeHadithDBHelper.dbName);
    } else {
      final dbPath = await getDatabasesPath();
      fakeHadithPath = join(dbPath, FakeHadithDBHelper.dbName);
    }
    paths.add(fakeHadithPath);
    return paths;
  }

  Future<bool> exportData() async {
    try {
      final archive = Archive();

      // Gather GetStorage preferences
      final box = GetStorage(kAppStorageKey);
      final keys = box.getKeys<Iterable<String>>();
      final Map<String, dynamic> prefsMap = {};
      for (final key in keys) {
        prefsMap[key] = box.read(key);
      }
      final prefsJson = jsonEncode(prefsMap);
      final prefsBytes = utf8.encode(prefsJson);

      archive.addFile(ArchiveFile('preferences.json', prefsBytes.length, prefsBytes));

      // Gather Databases
      final dbPaths = await _getDbPaths();
      for (final path in dbPaths) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(basename(path), bytes.length, bytes));
        }
      }

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes.isEmpty) return false;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup',
          fileName: 'hisnelmoslem_backup.hisn',
          type: FileType.custom,
          allowedExtensions: ['hisn'],
        );
        if (outputFile != null) {
          final targetPath = outputFile.endsWith('.hisn') ? outputFile : '$outputFile.hisn';
          await File(targetPath).writeAsBytes(zipBytes);
          return true;
        }
        return false;
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(join(tempDir.path, 'hisnelmoslem_backup.hisn'));
        await tempFile.writeAsBytes(zipBytes);

        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(tempFile.path, mimeType: 'application/octet-stream')],
            subject: 'Hisn Elmoslem Backup',
          ),
        );

        return result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.dismissed;
      }
    } catch (e) {
      hisnPrint("Export failed: $e");
      return false;
    }
  }

  Future<bool> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) return false;

      final filePath = result.files.single.path;
      if (filePath == null) return false;

      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Close all DB connections before overriding files
      await userDataDBHelper.close();
      await tallyDatabaseHelper.close();
      await alarmDatabaseHelper.close();
      await fakeHadithDBHelper.close();

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          final fileName = file.name;

          if (fileName == 'preferences.json') {
            final jsonStr = utf8.decode(data);
            final Map<String, dynamic> prefsMap = jsonDecode(jsonStr) as Map<String, dynamic>;
            final box = GetStorage(kAppStorageKey);
            for (final entry in prefsMap.entries) {
              await box.write(entry.key, entry.value);
            }
          } else if (fileName.endsWith('.db')) {
            // Find which path it belongs to
            final dbPaths = await _getDbPaths();
            final targetPath = dbPaths.firstWhere(
              (path) => basename(path) == fileName,
              orElse: () => '',
            );

            if (targetPath.isNotEmpty) {
              final targetFile = File(targetPath);
              await targetFile.writeAsBytes(data, flush: true);
            }
          }
        }
      }

      return true;
    } catch (e) {
      hisnPrint("Import failed: $e");
      return false;
    }
  }
}
