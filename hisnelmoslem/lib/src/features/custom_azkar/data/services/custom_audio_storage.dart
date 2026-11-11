import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the user's recordings are kept. Only file names are stored in the
/// database, so backups and reinstalls keep working when the base folder moves.
abstract interface class CustomAudioStorage {
  /// Folder that holds every recording (created on demand).
  Future<Directory> directory();

  /// A fresh, unique file name for a new recording.
  String newFileName();

  /// Absolute path of [fileName].
  Future<String> pathFor(String fileName);

  /// Whether the recording exists on disk.
  Future<bool> exists(String fileName);

  /// Removes the recording. Missing files are ignored.
  Future<void> delete(String fileName);

  /// Removes every recording whose name is not in [keep]. Returns how many were removed.
  Future<int> deleteUnreferenced(Set<String> keep);
}

class LocalCustomAudioStorage implements CustomAudioStorage {
  static const String folderName = "custom_audio";
  static const String extension = ".m4a";

  /// Used by tests. Null in production (app documents folder).
  final Directory? directoryOverride;

  const LocalCustomAudioStorage({this.directoryOverride});

  @override
  Future<Directory> directory() async {
    final dir =
        directoryOverride ??
        Directory(p.join((await getApplicationDocumentsDirectory()).path, folderName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  String newFileName() => "rec_${DateTime.now().microsecondsSinceEpoch}$extension";

  @override
  Future<String> pathFor(String fileName) async {
    // basename guards against a tampered database pointing outside the folder.
    return p.join((await directory()).path, p.basename(fileName));
  }

  @override
  Future<bool> exists(String fileName) async => File(await pathFor(fileName)).exists();

  @override
  Future<void> delete(String fileName) async {
    final file = File(await pathFor(fileName));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<int> deleteUnreferenced(Set<String> keep) async {
    var removed = 0;
    await for (final entity in (await directory()).list()) {
      if (entity is File && !keep.contains(p.basename(entity.path))) {
        await entity.delete();
        removed++;
      }
    }
    return removed;
  }
}
