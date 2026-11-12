import 'dart:async';
import 'dart:io';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:http/http.dart' as http;

/// Lets the caller stop a running download. The unfinished `.part` file is kept for a later resume.
class DownloadCancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class DownloadCancelled implements Exception {
  const DownloadCancelled();
  @override
  String toString() => 'DownloadCancelled';
}

/// The server answered with an error that retrying will not fix (for example 404).
class DownloadFailed implements Exception {
  final String message;
  const DownloadFailed(this.message);
  @override
  String toString() => 'DownloadFailed: $message';
}

/// Downloads one file to disk. Interface so the cubits can use a fake in tests.
abstract class AudioDownloader {
  /// Downloads [url] to [target] and returns the number of bytes of the finished file.
  ///
  /// A finished [target] is left alone. The data goes to `<target>.part` first, so a stopped
  /// download resumes from where it stopped. Throws [DownloadCancelled] or [DownloadFailed].
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  });

  /// Size of [url] in bytes from a HEAD request, or null when the server does not say.
  Future<int?> contentLength(String url);
}

class HttpAudioDownloader implements AudioDownloader {
  final http.Client client;
  final int maxAttempts;

  /// Wait before attempt n (1-based). Zero in tests.
  final Duration Function(int attempt) retryDelay;

  /// Longest silence tolerated while the body is arriving.
  final Duration idleTimeout;

  HttpAudioDownloader({
    required this.client,
    this.maxAttempts = 4,
    this.retryDelay = _defaultDelay,
    this.idleTimeout = const Duration(seconds: 30),
  });

  static Duration _defaultDelay(int attempt) => Duration(seconds: attempt * 2);

  @override
  Future<int?> contentLength(String url) async {
    try {
      final response = await client.head(Uri.parse(url)).timeout(idleTimeout);
      if (response.statusCode != 200) return null;
      return int.tryParse(response.headers['content-length'] ?? '');
    } catch (e) {
      hisnPrint('contentLength failed for $url: $e');
      return null;
    }
  }

  @override
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  }) async {
    if (await target.exists() && await target.length() > 0) return target.length();

    await target.parent.create(recursive: true);
    final part = File('${target.path}.part');

    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (cancel?.isCancelled ?? false) throw const DownloadCancelled();
      if (attempt > 1) await Future<void>.delayed(retryDelay(attempt - 1));
      try {
        final size = await _fetchInto(url, part, onProgress, cancel);
        await part.rename(target.path);
        return size;
      } on DownloadCancelled {
        rethrow;
      } on DownloadFailed {
        rethrow;
      } catch (e) {
        lastError = e;
        hisnPrint('download attempt $attempt of $url failed: $e');
      }
    }
    throw DownloadFailed('$url: $lastError');
  }

  /// One attempt: continues [part] with a Range request and returns the final size.
  /// Throws a retryable error when the body ended early.
  Future<int> _fetchInto(
    String url,
    File part,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  ) async {
    var have = await part.exists() ? await part.length() : 0;

    final request = http.Request('GET', Uri.parse(url));
    if (have > 0) request.headers['range'] = 'bytes=$have-';
    final response = await client.send(request).timeout(idleTimeout);

    var restart = false;
    switch (response.statusCode) {
      case 200:
        restart = true; // no resume support (or a fresh start): take the whole body
      case 206:
        break;
      case 416:
        // The part file does not fit the server's file any more: start again.
        await part.delete();
        throw StateError('range not satisfiable, restarting');
      case >= 500 || 408 || 429:
        throw StateError('server answered ${response.statusCode}');
      default:
        throw DownloadFailed('$url answered ${response.statusCode}');
    }
    if (restart) have = 0;

    final total = _totalSize(response, have);
    final sink = part.openWrite(mode: restart ? FileMode.write : FileMode.append);
    var received = have;
    try {
      await for (final chunk in response.stream.timeout(idleTimeout)) {
        if (cancel?.isCancelled ?? false) throw const DownloadCancelled();
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }

    if (total != null && received != total) {
      throw StateError('body ended early: $received of $total bytes');
    }
    return received;
  }

  /// Whole file size from `Content-Range: bytes a-b/total`, or content-length + what we have.
  int? _totalSize(http.StreamedResponse response, int have) {
    final range = response.headers['content-range'];
    if (range != null) {
      final total = int.tryParse(range.split('/').last);
      if (total != null) return total;
    }
    final length = response.contentLength;
    if (length == null) return null;
    return response.statusCode == 206 ? have + length : length;
  }
}
