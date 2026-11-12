import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

void main() {
  group('AudioFileStore.keyOf', () {
    test('keeps the upload folders so same-named files of different months do not clash', () {
      expect(
        AudioFileStore.keyOf('https://cdn.binwahaf.com/uploads/2025/12/0002.mp3'),
        '2025_12_0002.mp3',
      );
      expect(
        AudioFileStore.keyOf('https://cdn.binwahaf.com/uploads/2026/01/0002.mp3'),
        '2026_01_0002.mp3',
      );
    });

    test('works with percent-encoded Arabic names and other urls', () {
      final key = AudioFileStore.keyOf(
        'https://cdn.binwahaf.com/uploads/2026/01/${Uri.encodeComponent('فضل-الذكر-1.mp3')}',
      );
      expect(key, '2026_01_فضل-الذكر-1.mp3');
      expect(AudioFileStore.keyOf('https://x.com/a/b.mp3'), 'b.mp3');
    });
  });

  group('AudioFileStore on disk', () {
    late Directory root;
    late AudioFileStore store;
    const url = 'https://cdn.binwahaf.com/uploads/2025/12/0002.mp3';

    setUp(() async {
      root = await Directory.systemTemp.createTemp('reciter_audio_test');
      store = AudioFileStore(() async => root);
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('a finished file is found, an unfinished .part and an empty file are not', () async {
      expect(await store.existingPath(Reciter.hamadAlduraihem, url), isNull);

      final file = await store.fileOf(Reciter.hamadAlduraihem, url);
      await file.parent.create(recursive: true);
      await File('${file.path}.part').writeAsBytes([1, 2, 3]);
      expect(await store.existingPath(Reciter.hamadAlduraihem, url), isNull);

      await file.writeAsBytes([]);
      expect(await store.existingPath(Reciter.hamadAlduraihem, url), isNull);

      await file.writeAsBytes([1, 2, 3, 4]);
      expect(await store.existingPath(Reciter.hamadAlduraihem, url), file.path);
      expect(await store.existingPath(Reciter.rashidAlhulaibah, url), isNull);
    });

    test('size counts finished files only and delete removes the reciter folder', () async {
      final a = await store.fileOf(Reciter.rashidAlhulaibah, url);
      await a.parent.create(recursive: true);
      await a.writeAsBytes(List.filled(10, 1));
      await File('${a.path}.part').writeAsBytes(List.filled(99, 1));

      expect(await store.sizeOf(Reciter.rashidAlhulaibah), 10);
      expect((await store.downloadedFiles(Reciter.rashidAlhulaibah)).keys, ['2025_12_0002.mp3']);

      await store.deleteReciter(Reciter.rashidAlhulaibah);
      expect(await store.sizeOf(Reciter.rashidAlhulaibah), 0);
      expect(await store.reciterDir(Reciter.rashidAlhulaibah).then((d) => d.exists()), isFalse);
    });
  });
}
