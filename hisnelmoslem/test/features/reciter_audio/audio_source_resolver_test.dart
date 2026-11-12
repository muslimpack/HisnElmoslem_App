import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_choice.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_resolver.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

DbContent zikr({
  String audio = '',
  String userAudioPath = '',
  Map<String, List<String>> urls = const {},
  bool remoteOk = true,
}) {
  return DbContent(
    id: 1,
    content: 'x',
    titleId: 1,
    order: 1,
    count: 1,
    fadl: '',
    source: '',
    search: '',
    hokm: '',
    audio: audio,
    hasAudio: audio.isNotEmpty,
    audioUrls: urls,
    audioRemoteOk: remoteOk,
    userAudioPath: userAudioPath,
  );
}

AudioSourceResolver resolver({Set<String> downloaded = const {}, bool online = true}) {
  return AudioSourceResolver(
    downloadedPath: (reciter, url) =>
        downloaded.contains('${reciter.slug}|$url') ? '/files/${reciter.slug}/$url' : null,
    isOnline: () => online,
  );
}

void main() {
  const urls = {
    'hamad_alduraihem': ['https://cdn/h.mp3'],
    'rashid_alhulaibah': ['https://cdn/r1.mp3', 'https://cdn/r2.mp3'],
  };

  group('AudioSourceResolver', () {
    test('the user recording wins over everything', () {
      final choice = resolver().resolve(
        zikr(audio: 'a.mp3', userAudioPath: '/rec.m4a', urls: urls),
        Reciter.rashidAlhulaibah,
      );
      expect(choice, const UserRecording('/rec.m4a'));
    });

    test('the bundled reciter keeps the bundled file even when a download exists', () {
      final choice = resolver(downloaded: {'hamad_alduraihem|https://cdn/h.mp3'}).resolve(
        zikr(audio: 'a.mp3', urls: urls),
        Reciter.hamadAlduraihem,
      );
      expect(choice, const BundledAsset('a.mp3'));
    });

    test('another reciter replaces the bundled file when it has a recording', () {
      final choice = resolver().resolve(zikr(audio: 'a.mp3', urls: urls), Reciter.rashidAlhulaibah);
      expect(choice, const StreamUrls(['https://cdn/r1.mp3', 'https://cdn/r2.mp3']));
    });

    test('another reciter falls back to the bundled file when it has no usable recording', () {
      final choice = resolver().resolve(
        zikr(audio: 'a.mp3', urls: urls, remoteOk: false),
        Reciter.rashidAlhulaibah,
      );
      expect(choice, const BundledAsset('a.mp3'));
      final noUrl = resolver().resolve(zikr(audio: 'a.mp3'), Reciter.sulaimanAlshuwaihi);
      expect(noUrl, const BundledAsset('a.mp3'));
    });

    test('downloaded files are used only when every part is there', () {
      final partial = resolver(downloaded: {'rashid_alhulaibah|https://cdn/r1.mp3'}).resolve(
        zikr(urls: urls),
        Reciter.rashidAlhulaibah,
      );
      expect(partial, isA<StreamUrls>());

      final all = resolver(
        downloaded: {
          'rashid_alhulaibah|https://cdn/r1.mp3',
          'rashid_alhulaibah|https://cdn/r2.mp3',
        },
      ).resolve(zikr(urls: urls), Reciter.rashidAlhulaibah);
      expect(
        all,
        const DownloadedFiles([
          '/files/rashid_alhulaibah/https://cdn/r1.mp3',
          '/files/rashid_alhulaibah/https://cdn/r2.mp3',
        ]),
      );
    });

    test('offline without a download gives no audio', () {
      final choice = resolver(online: false).resolve(zikr(urls: urls), Reciter.hamadAlduraihem);
      expect(choice, const NoAudio());
    });

    test('a zikr that is not remote-ok never streams or uses downloads', () {
      final choice = resolver(downloaded: {'hamad_alduraihem|https://cdn/h.mp3'}).resolve(
        zikr(urls: urls, remoteOk: false),
        Reciter.hamadAlduraihem,
      );
      expect(choice, const NoAudio());
    });
  });

  group('DbContent.parseAudioUrls', () {
    test('accepts a url or a list of urls', () {
      expect(
        DbContent.parseAudioUrls('{"a":"u1","b":["u2","u3"]}'),
        {
          'a': ['u1'],
          'b': ['u2', 'u3'],
        },
      );
    });

    test('malformed or empty input gives an empty map', () {
      expect(DbContent.parseAudioUrls(null), isEmpty);
      expect(DbContent.parseAudioUrls(''), isEmpty);
      expect(DbContent.parseAudioUrls('not json'), isEmpty);
      expect(DbContent.parseAudioUrls('[1,2]'), isEmpty);
      expect(DbContent.parseAudioUrls('{"a":5}'), isEmpty);
    });

    test('fromMap reads the new columns', () {
      final z = DbContent.fromMap(const {
        'id': 1,
        'content': 'x',
        'titleId': 1,
        'order': 1,
        'count': 1,
        'audio_urls': '{"hamad_alduraihem":"u"}',
        'audio_remote_ok': 1,
      });
      expect(z.audioRemoteOk, isTrue);
      expect(z.audioUrls['hamad_alduraihem'], ['u']);
    });
  });
}
