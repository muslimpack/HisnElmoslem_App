import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A tiny file server: honours `Range: bytes=n-` unless [supportRange] is false.
class FakeServer {
  final List<int> body;
  final bool supportRange;
  final List<int> statuses; // forced status codes for the first requests
  final int? cutAfter; // the first successful body ends after this many bytes
  int requests = 0;
  final List<String?> ranges = [];

  FakeServer(this.body, {this.supportRange = true, this.statuses = const [], this.cutAfter});

  late final MockClient client = MockClient.streaming((request, _) async {
    final n = requests++;
    ranges.add(request.headers['range']);
    if (n < statuses.length) {
      return http.StreamedResponse(const Stream.empty(), statuses[n]);
    }
    var start = 0;
    final range = request.headers['range'];
    if (range != null && supportRange) {
      start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
    }
    var data = body.sublist(start);
    final isFirstGood = n == statuses.length;
    if (cutAfter != null && isFirstGood) data = data.sublist(0, cutAfter);
    final partial = range != null && supportRange;
    return http.StreamedResponse(
      Stream.fromIterable([
        for (var i = 0; i < data.length; i += 4) data.sublist(i, (i + 4).clamp(0, data.length)),
      ]),
      partial ? 206 : 200,
      contentLength: partial ? body.length - start : body.length,
      headers: partial ? {'content-range': 'bytes $start-${body.length - 1}/${body.length}'} : {},
    );
  });
}

void main() {
  late Directory dir;
  late File target;
  final body = List<int>.generate(50, (i) => i);

  HttpAudioDownloader downloader(FakeServer s, {int attempts = 4}) => HttpAudioDownloader(
    client: s.client,
    maxAttempts: attempts,
    retryDelay: (_) => Duration.zero,
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('downloader_test');
    target = File('${dir.path}/a/b.mp3');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('downloads the whole file and reports progress', () async {
    final server = FakeServer(body);
    final progress = <int>[];
    final size = await downloader(server).download(
      url: 'https://x/a.mp3',
      target: target,
      onProgress: (received, total) {
        progress.add(received);
        expect(total, 50);
      },
    );
    expect(size, 50);
    expect(await target.readAsBytes(), body);
    expect(File('${target.path}.part').existsSync(), isFalse);
    expect(progress.last, 50);
  });

  test('a finished file is not downloaded again', () async {
    final server = FakeServer(body);
    await target.parent.create(recursive: true);
    await target.writeAsBytes([9, 9, 9]);
    expect(await downloader(server).download(url: 'https://x/a.mp3', target: target), 3);
    expect(server.requests, 0);
  });

  test('resumes a .part file with a Range request', () async {
    final server = FakeServer(body);
    await target.parent.create(recursive: true);
    await File('${target.path}.part').writeAsBytes(body.sublist(0, 20));

    await downloader(server).download(url: 'https://x/a.mp3', target: target);

    expect(server.ranges.first, 'bytes=20-');
    expect(await target.readAsBytes(), body);
  });

  test('starts over when the server ignores the Range header', () async {
    final server = FakeServer(body, supportRange: false);
    await target.parent.create(recursive: true);
    await File('${target.path}.part').writeAsBytes([7, 7, 7, 7]);

    await downloader(server).download(url: 'https://x/a.mp3', target: target);

    expect(await target.readAsBytes(), body);
  });

  test('retries after a server error', () async {
    final server = FakeServer(body, statuses: [503, 500]);
    await downloader(server).download(url: 'https://x/a.mp3', target: target);
    expect(server.requests, 3);
    expect(await target.readAsBytes(), body);
  });

  test('a body that ends early is continued by the next attempt', () async {
    final server = FakeServer(body, cutAfter: 12);
    await downloader(server).download(url: 'https://x/a.mp3', target: target);
    expect(server.ranges.last, 'bytes=12-');
    expect(await target.readAsBytes(), body);
  });

  test('a 404 fails at once without retrying', () async {
    final server = FakeServer(body, statuses: [404]);
    await expectLater(
      downloader(server).download(url: 'https://x/a.mp3', target: target),
      throwsA(isA<DownloadFailed>()),
    );
    expect(server.requests, 1);
    expect(target.existsSync(), isFalse);
  });

  test('gives up after the attempts are used', () async {
    final server = FakeServer(body, statuses: [500, 500, 500]);
    await expectLater(
      downloader(server, attempts: 3).download(url: 'https://x/a.mp3', target: target),
      throwsA(isA<DownloadFailed>()),
    );
    expect(server.requests, 3);
  });

  test('cancelling keeps the .part file for a later resume', () async {
    final server = FakeServer(body);
    final token = DownloadCancelToken();
    await expectLater(
      downloader(server).download(
        url: 'https://x/a.mp3',
        target: target,
        cancel: token,
        onProgress: (received, _) {
          if (received >= 8) token.cancel();
        },
      ),
      throwsA(isA<DownloadCancelled>()),
    );
    expect(target.existsSync(), isFalse);
    final part = File('${target.path}.part');
    expect(part.existsSync(), isTrue);
    expect(await part.length(), inInclusiveRange(8, 12));
  });

  test('contentLength reads the HEAD response and tolerates failures', () async {
    final ok = HttpAudioDownloader(
      client: MockClient((_) async => http.Response('', 200, headers: {'content-length': '1234'})),
    );
    expect(await ok.contentLength('https://x/a.mp3'), 1234);

    final bad = HttpAudioDownloader(
      client: MockClient((_) async => throw const SocketException('x')),
    );
    expect(await bad.contentLength('https://x/a.mp3'), isNull);
  });
}
