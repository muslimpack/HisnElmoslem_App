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

  /// Marks a recording as in use by an unsaved draft, so [deleteUnreferenced] skips it.
  void pin(String fileName);
  void unpin(String fileName);

  /// Lets another feature say which recordings it still uses (for example the tally
  /// counters), so a sweep by this storage's owner never deletes them.
  void addReferenceProvider(Future<Set<String>> Function() provider);

  /// Removes every recording that is neither in [keep], pinned, nor (unless
  /// [includeExternal] is false) used by a registered reference provider. Returns how
  /// many were removed.
  Future<int> deleteUnreferenced(Set<String> keep, {bool includeExternal = true});
}

class LocalCustomAudioStorage implements CustomAudioStorage {
  static const String folderName = "custom_audio";
  static const String extension = ".m4a";

  /// Used by tests. Null in production (app documents folder).
  final Directory? directoryOverride;

  final Set<String> _pinned = {};
  final List<Future<Set<String>> Function()> _referenceProviders = [];

  LocalCustomAudioStorage({this.directoryOverride});

  @override
  void addReferenceProvider(Future<Set<String>> Function() provider) {
    _referenceProviders.add(provider);
  }

  @override
  void pin(String fileName) => _pinned.add(p.basename(fileName));

  @override
  void unpin(String fileName) => _pinned.remove(p.basename(fileName));

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
  Future<int> deleteUnreferenced(Set<String> keep, {bool includeExternal = true}) async {
    final kept = {...keep};
    if (includeExternal) {
      for (final provider in _referenceProviders) {
        kept.addAll(await provider());
      }
    }
    var removed = 0;
    await for (final entity in (await directory()).list()) {
      final name = p.basename(entity.path);
      if (entity is File && !kept.contains(name) && !_pinned.contains(name)) {
        await entity.delete();
        removed++;
      }
    }
    return removed;
  }
}
