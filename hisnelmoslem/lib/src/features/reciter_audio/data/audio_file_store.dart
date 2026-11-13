import 'dart:io';

import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:path/path.dart' as p;

/// Where downloaded reciter recordings live: `<root>/reciter_audio/<slug>/<key>`.
///
/// The key comes from the url, so zikrs that share a lesson share one file.
class AudioFileStore {
  final Future<Directory> Function() rootProvider;
  AudioFileStore(this.rootProvider);

  static const String folderName = 'reciter_audio';

  /// A file-system safe key for [url], e.g. `2025_12_0002.mp3` for `.../uploads/2025/12/0002.mp3`.
  static String keyOf(String url) {
    final segments = Uri.parse(url).pathSegments;
    final afterUploads = segments.skipWhile((s) => s != 'uploads').skip(1).toList();
    final parts = [
      if (afterUploads.isNotEmpty)
        ...afterUploads
      else if (segments.isEmpty)
        url
      else
        segments.last,
    ];
    final key = parts.join('_').replaceAll(RegExp(r'[^\w؀-ۿ.\-]+'), '-');
    return key.isEmpty ? 'audio' : key;
  }

  Future<Directory> reciterDir(Reciter reciter) async {
    final root = await rootProvider();
    return Directory(p.join(root.path, folderName, reciter.slug));
  }

  Future<File> fileOf(Reciter reciter, String url) async {
    final dir = await reciterDir(reciter);
    return File(p.join(dir.path, keyOf(url)));
  }

  /// Path of the finished download, or null (an unfinished `.part` does not count).
  Future<String?> existingPath(Reciter reciter, String url) async {
    final file = await fileOf(reciter, url);
    if (await file.exists() && await file.length() > 0) return file.path;
    return null;
  }

  /// Finished files of [reciter]: file name to size in bytes.
  Future<Map<String, int>> downloadedFiles(Reciter reciter) async {
    final dir = await reciterDir(reciter);
    if (!await dir.exists()) return {};
    final result = <String, int>{};
    await for (final e in dir.list()) {
      if (e is File && !e.path.endsWith('.part')) result[p.basename(e.path)] = await e.length();
    }
    return result;
  }

  Future<int> sizeOf(Reciter reciter) async {
    final files = await downloadedFiles(reciter);
    return files.values.fold<int>(0, (a, b) => a + b);
  }

  Future<void> deleteReciter(Reciter reciter) async {
    final dir = await reciterDir(reciter);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
