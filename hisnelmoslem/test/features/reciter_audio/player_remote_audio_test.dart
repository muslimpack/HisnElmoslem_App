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

  @override
  Stream<void> get onPlayerComplete => complete.stream;
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
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
    if (failStreams && source is UrlSource) throw Exception('no network');
    playedSources.add(source);
  }

  @override
  Future<void> stop() async {}
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
}
