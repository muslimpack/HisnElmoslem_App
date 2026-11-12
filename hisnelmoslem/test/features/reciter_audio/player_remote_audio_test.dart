import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_resolver.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Stands in for the platform player, which cannot run in unit tests.
class FakePlayer extends Fake implements AudioPlayer {
  final complete = StreamController<void>.broadcast();
  final position = StreamController<Duration>.broadcast();
  final duration = StreamController<Duration>.broadcast();
  int stops = 0;
  final playedSources = <Source>[];

  /// Sources have no equality, so tests compare these readable forms.
  List<String> get played => [for (final s in playedSources) describe(s)];

  static String describe(Source s) => switch (s) {
    UrlSource(:final url) => 'url:$url',
    AssetSource(:final path) => 'asset:$path',
    DeviceFileSource(:final path) => 'file:$path',
    _ => s.toString(),
  };

  /// Makes `play` throw for sources of this type, like a stream that cannot be loaded.
  bool failStreams = false;

  /// Holds `play` of a stream until completed, like a slow network.
  Completer<void>? streamGate;

  @override
  Stream<void> get onPlayerComplete => complete.stream;
  @override
  Stream<Duration> get onPositionChanged => position.stream;
  @override
  Stream<Duration> get onDurationChanged => duration.stream;
  @override
  String get playerId => 'fake';

  @override
  Future<void> setAudioContext(AudioContext audioContext) async {}
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    if (source is UrlSource) await streamGate?.future;
    if (failStreams && source is UrlSource) throw Exception('no network');
    playedSources.add(source);
  }

  @override
  Future<void> stop() async => stops++;
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setPlaybackRate(double playbackRate) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {}
}

DbContent zikr(
  int id, {
  String audio = '',
  Map<String, List<String>> urls = const {},
  bool remoteOk = true,
  int count = 1,
}) => DbContent(
  id: id,
  content: 'zikr $id',
  titleId: 1,
  order: id,
  count: count,
  fadl: '',
  source: '',
  search: '',
  hokm: '',
  audio: audio,
  hasAudio: audio.isNotEmpty,
  audioUrls: urls,
  audioRemoteOk: remoteOk,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('remote_audio_test').path,
    );
    await GetStorage.init('remote_audio_test');
  });

  late FakePlayer player;
  late ZikrAudioPlayerCubit cubit;
  var selected = Reciter.hamadAlduraihem;
  var streaming = true;
  final downloaded = <String>{};

  Future<void> start(List<DbContent> list) async {
    cubit = ZikrAudioPlayerCubit(
      ZikrAudioPlayerRepo(GetStorage('remote_audio_test')),
      player: player,
      reciter: () => selected,
      resolver: AudioSourceResolver(
        downloadedPath: (reciter, url) async =>
            downloaded.contains(url) ? '/dl/${reciter.slug}.mp3' : null,
        isOnline: () => streaming,
      ),
    );
    await cubit.init(zikrList: list);
    await cubit.saveSettings(delayType: AudioDelayTypeEnum.none);
  }

  setUp(() {
    player = FakePlayer();
    selected = Reciter.hamadAlduraihem;
    streaming = true;
    downloaded.clear();
  });

  tearDown(() => cubit.close());

  const urls = {
    'hamad_alduraihem': ['https://cdn/h.mp3'],
    'rashid_alhulaibah': ['https://cdn/r1.mp3', 'https://cdn/r2.mp3'],
  };

  test('a zikr without a bundled file streams the selected reciter', () async {
    await start([zikr(1, urls: urls)]);
    await cubit.startPlayFromIndex(0);

    expect(player.played, ['url:https://cdn/h.mp3']);
    expect(cubit.state.isPlaying, isTrue);
  });

  test('the bundled file is kept for the bundled reciter', () async {
    await start([zikr(1, audio: 'a.mp3', urls: urls)]);
    await cubit.startPlayFromIndex(0);

    expect(player.played, ['asset:sounds/azkar/a.mp3']);
  });

  test('a downloaded file is played instead of streaming', () async {
    downloaded.add('https://cdn/h.mp3');
    await start([zikr(1, urls: urls)]);
    await cubit.startPlayFromIndex(0);

    expect(player.played, ['file:/dl/hamad_alduraihem.mp3']);
  });

  test('a zikr with two recordings plays both and is done only after the second', () async {
    selected = Reciter.rashidAlhulaibah;
    await start([zikr(1, urls: urls), zikr(2)]);
    var done = 0;
    cubit.onDonePlaying = (_) => done++;

    await cubit.startPlayFromIndex(0);
    expect(player.played, ['url:https://cdn/r1.mp3']);

    player.complete.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(player.played, ['url:https://cdn/r1.mp3', 'url:https://cdn/r2.mp3']);
    expect(done, 0);

    player.complete.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(done, 1);
  });

  test('with streaming off a zikr that is not downloaded ends narration', () async {
    streaming = false;
    await start([zikr(1, urls: urls)]);
    await cubit.startPlayFromIndex(0);

    expect(player.playedSources, isEmpty);
    expect(cubit.state.isPlaying, isFalse);
  });

  test('a stream that cannot be loaded ends narration instead of hanging', () async {
    player.failStreams = true;
    await start([zikr(1, urls: urls)]);
    await cubit.startPlayFromIndex(0);

    expect(player.playedSources, isEmpty);
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.isPaused, isFalse);
  });

  test('a zikr that is not remote-ok never streams', () async {
    await start([zikr(1, urls: urls, remoteOk: false)]);
    await cubit.startPlayFromIndex(0);

    expect(player.playedSources, isEmpty);
  });

  test('hasPlayableAudio is true for a zikr that only has a remote recording', () {
    expect(zikr(1, urls: urls).hasPlayableAudio, isTrue);
    expect(zikr(1, urls: urls, remoteOk: false).hasPlayableAudio, isFalse);
    expect(zikr(1).hasPlayableAudio, isFalse);
  });

  test('a stream shows as loading until it starts, then stops showing', () async {
    player.streamGate = Completer<void>();
    await start([zikr(1, urls: urls)]);

    final play = cubit.startPlayFromIndex(0);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.isLoadingAudio, isTrue);

    player.streamGate!.complete();
    await play;
    expect(cubit.state.isLoadingAudio, isFalse);
    expect(cubit.state.isPlaying, isTrue);
  });

  test('loading ends when the stream cannot be loaded, and when it is stopped meanwhile', () async {
    player.failStreams = true;
    await start([zikr(1, urls: urls)]);
    await cubit.startPlayFromIndex(0);
    expect(cubit.state.isLoadingAudio, isFalse);

    player
      ..failStreams = false
      ..streamGate = Completer<void>();
    final play = cubit.startPlayFromIndex(0);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.isLoadingAudio, isTrue);
    await cubit.stop();
    expect(cubit.state.isLoadingAudio, isFalse);
    player.streamGate!.complete();
    await play;
  });

  test('a bundled file never shows the loading state', () async {
    await start([zikr(1, audio: 'a.mp3')]);
    await cubit.startPlayFromIndex(0);
    expect(cubit.state.isLoadingAudio, isFalse);
  });

  group('count spoken at the end of a recording from the website', () {
    Future<void> reach(Duration total, Duration at) async {
      player.duration.add(total);
      await Future<void>.delayed(Duration.zero);
      player.position.add(at);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    test('the end of a repeated zikr is skipped, and the next repetition starts', () async {
      await start([zikr(1, urls: urls, count: 3)]);
      cubit.getActiveZikrCount = (_) => 3;
      var done = 0;
      cubit.onDonePlaying = (_) => done++;

      await cubit.startPlayFromIndex(0);
      await reach(const Duration(seconds: 10), const Duration(seconds: 7));
      expect(done, 0, reason: 'before the last 1.8 seconds nothing is cut');

      await reach(const Duration(seconds: 10), const Duration(milliseconds: 8300));
      expect(done, 1);
      expect(player.stops, greaterThan(0));
    });

    test('a zikr that is not repeated plays to its end', () async {
      await start([zikr(1, urls: urls)]);
      var done = 0;
      cubit.onDonePlaying = (_) => done++;

      await cubit.startPlayFromIndex(0);
      await reach(const Duration(seconds: 10), const Duration(milliseconds: 9500));
      expect(done, 0);
    });

    test('the bundled recording is never cut', () async {
      await start([zikr(1, audio: 'a.mp3', urls: urls, count: 3)]);
      var done = 0;
      cubit.onDonePlaying = (_) => done++;

      await cubit.startPlayFromIndex(0);
      await reach(const Duration(seconds: 10), const Duration(milliseconds: 9500));
      expect(done, 0);
    });

    test('a short recording is left alone', () async {
      await start([zikr(1, urls: urls, count: 3)]);
      var done = 0;
      cubit.onDonePlaying = (_) => done++;

      await cubit.startPlayFromIndex(0);
      await reach(const Duration(seconds: 4), const Duration(milliseconds: 3500));
      expect(done, 0);
    });

    test('only the last of several recordings is cut', () async {
      selected = Reciter.rashidAlhulaibah;
      await start([zikr(1, urls: urls, count: 3)]);
      cubit.getActiveZikrCount = (_) => 3;
      var done = 0;
      cubit.onDonePlaying = (_) => done++;

      await cubit.startPlayFromIndex(0);
      await reach(const Duration(seconds: 10), const Duration(milliseconds: 9500));
      expect(done, 0, reason: 'the first of two recordings plays on');

      player.complete.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await reach(const Duration(seconds: 10), const Duration(milliseconds: 9000));
      expect(done, 1);
    });
  });
}
