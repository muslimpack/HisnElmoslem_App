import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/error_log_store.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('error_log_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  ErrorLogStore store({int max = 30}) => ErrorLogStore(() async => dir, maxEntries: max);

  test('records errors and keeps only the newest ones', () async {
    final s = store(max: 3);
    for (var i = 0; i < 5; i++) {
      s.record(Exception('e$i'), StackTrace.current, source: 'test');
    }
    await s.flush();
    final recent = await s.recent(10);
    expect(recent.map((e) => e.error), [
      'Exception: e2',
      'Exception: e3',
      'Exception: e4',
    ]);
  });

  test('errors survive a restart and come before new ones', () async {
    final first = store()..record('old', null);
    await first.flush();

    final second = store()..record('new', null);
    await second.flush();
    final recent = await second.recent();
    expect(recent.map((e) => e.error), ['old', 'new']);
  });

  test('report file holds the errors, and is not written when there are none', () async {
    final empty = await store().writeReportFile(header: 'h', tempDir: dir);
    expect(empty, isNull);

    final s = store()..record('boom', StackTrace.current, source: 'flutter');
    await s.flush();
    final path = await s.writeReportFile(header: 'Header', tempDir: dir);
    final text = File(path!).readAsStringSync();
    expect(text, contains('Header'));
    expect(text, contains('boom'));
    expect(text, contains('(flutter)'));
  });
}
