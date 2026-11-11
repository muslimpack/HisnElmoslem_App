import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:path/path.dart' as p;

/// Puts the user's recordings into a backup archive and takes them out again.
/// Recordings live under [prefix] inside the archive, next to the database files.
class CustomAudioBackup {
  static const String prefix = "custom_audio/";

  final CustomAudioStorage storage;

  const CustomAudioBackup(this.storage);

  Future<void> addTo(Archive archive) async {
    await for (final entity in (await storage.directory()).list()) {
      if (entity is! File) continue;
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile("$prefix${p.basename(entity.path)}", bytes.length, bytes));
    }
  }

  /// Restores the recordings found in [archive]. When the archive also carries the
  /// custom azkar database, the recordings on the device are replaced, because that
  /// database no longer refers to them.
  Future<void> restoreFrom(Archive archive) async {
    final hasDatabase = archive.any((f) => f.isFile && f.name == CustomAzkarDBHelper.dbName);
    if (hasDatabase) await storage.deleteUnreferenced(const {});

    for (final file in archive) {
      if (!file.isFile || !file.name.startsWith(prefix)) continue;
      final name = p.basename(file.name);
      if (name.isEmpty) continue;
      await File(await storage.pathFor(name)).writeAsBytes(file.content as List<int>, flush: true);
    }
  }
}
