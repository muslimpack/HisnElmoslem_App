import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// One captured error.
class ErrorLogEntry {
  final DateTime time;
  final String source;
  final String error;
  final String stack;

  const ErrorLogEntry({
    required this.time,
    required this.source,
    required this.error,
    required this.stack,
  });

  Map<String, Object> toJson() => {
    't': time.toIso8601String(),
    's': source,
    'e': error,
    'st': stack,
  };

  static ErrorLogEntry? tryParse(String line) {
    try {
      final map = jsonDecode(line) as Map<String, dynamic>;
      return ErrorLogEntry(
        time: DateTime.parse(map['t'] as String),
        source: map['s'] as String,
        error: map['e'] as String,
        stack: map['st'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Keeps the last errors of the app in a small file so a bug report can include them.
///
/// Nothing leaves the device by itself: the log is only attached to an email the user
/// chooses to send. Errors that happen before the folder is known are kept in memory.
class ErrorLogStore {
  ErrorLogStore(this._directory, {this.maxEntries = 30, this.maxStackLines = 40});

  final Future<Directory> Function() _directory;
  final int maxEntries;
  final int maxStackLines;

  final List<ErrorLogEntry> _entries = [];
  bool _loaded = false;
  Future<void> _queue = Future.value();

  /// Records an error. Never throws: logging must not create new errors.
  void record(Object error, StackTrace? stack, {String source = 'app'}) {
    final entry = ErrorLogEntry(
      time: DateTime.now(),
      source: source,
      error: _clip(error.toString(), 2000),
      stack: _trimStack(stack),
    );
    _entries.add(entry);
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    _queue = _queue.then((_) => _persist()).catchError((_) {});
  }

  /// Waits for pending writes (used by tests and before building a report).
  Future<void> flush() => _queue;

  /// The last [count] errors, oldest first, including those saved by earlier sessions.
  Future<List<ErrorLogEntry>> recent([int count = 5]) async {
    await _queue;
    await _load();
    final start = _entries.length > count ? _entries.length - count : 0;
    return List.unmodifiable(_entries.sublist(start));
  }

  /// The report as text (what is attached and what the preview shows).
  Future<String> reportText({
    required String header,
    int count = 5,
  }) async {
    final errors = await recent(count);
    if (errors.isEmpty) return '';
    final line = '-' * 40;
    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln(line);
    for (final e in errors) {
      buffer
        ..writeln('[${e.time.toIso8601String()}] (${e.source})')
        ..writeln(e.error)
        ..writeln()
        ..writeln(e.stack)
        ..writeln(line);
    }
    return buffer.toString();
  }

  /// Writes [reportText] to a temp file and returns its path, or null when there is no error.
  Future<String?> writeReportFile({
    required String header,
    required Directory tempDir,
    int count = 5,
  }) async {
    final text = await reportText(header: header, count: count);
    if (text.isEmpty) return null;
    final file = File(p.join(tempDir.path, 'hisn_error_report.txt'));
    await file.writeAsString(text);
    return file.path;
  }

  Future<File> _file() async {
    final dir = Directory(p.join((await _directory()).path, 'logs'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return File(p.join(dir.path, 'errors.log'));
  }

  /// Merges errors saved by earlier sessions in front of this session's, once.
  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final saved = (await file.readAsLines()).map(ErrorLogEntry.tryParse).nonNulls.toList();
      _entries.insertAll(0, saved);
      while (_entries.length > maxEntries) {
        _entries.removeAt(0);
      }
    } catch (_) {
      // An unreadable log is not worth failing for.
    }
  }

  Future<void> _persist() async {
    await _load();
    final file = await _file();
    final lines = _entries.map((e) => jsonEncode(e.toJson()));
    await file.writeAsString('${lines.join('\n')}\n');
  }

  String _trimStack(StackTrace? stack) {
    if (stack == null) return '';
    final lines = stack.toString().split('\n');
    return lines.take(maxStackLines).join('\n');
  }

  String _clip(String text, int max) => text.length <= max ? text : '${text.substring(0, max)}…';
}
