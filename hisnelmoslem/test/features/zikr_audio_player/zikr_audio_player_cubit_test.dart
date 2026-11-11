import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// [recorded] gives the zikr an audio file; a device file avoids loading app assets.
/// Stands in for the platform player, which cannot run in unit tests.
class FakePlayer extends Fake implements AudioPlayer {
  final complete = StreamController<void>.broadcast();
  final playedSources = <Source>[];

  @override
  Stream<void> get onPlayerComplete => complete.stream;
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
  @override
  String get playerId => "fake";

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
  }) async => playedSources.add(source);
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

DbContent zikr(int id, {bool recorded = false, int count = 1}) => DbContent(
  id: id,
  content: "zikr $id",
  titleId: 1,
  order: id,
  count: count,
  fadl: "",
  source: "",
  search: "",
  hokm: "",
  audio: "",
  hasAudio: false,
  userAudioPath: recorded ? "/tmp/zikr_$id.m4a" : "",
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // GetStorage keeps its file in the app documents folder.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('audio_cubit_test').path,
    );
    await GetStorage.init('audio_cubit_test');
  });

  late ZikrAudioPlayerCubit cubit;
  late FakePlayer player;

  setUp(() async {
    player = FakePlayer();
    cubit = ZikrAudioPlayerCubit(
      ZikrAudioPlayerRepo(GetStorage('audio_cubit_test')),
      player: player,
    );
    await cubit.init(
      zikrList: [
        zikr(1, recorded: true),
        zikr(2),
        zikr(3, recorded: true),
      ],
    );
  });

  tearDown(() => cubit.close());

  test("playing a zikr with audio marks narration as playing", () async {
    await cubit.startPlayFromIndex(0);
    expect(cubit.state.isPlaying, isTrue);
    expect(cubit.state.currentIndex, 0);
  });

  test("reaching a zikr without audio ends narration instead of leaving it 'playing'", () async {
    await cubit.startPlayFromIndex(0);
    expect(cubit.state.isPlaying, isTrue);

    await cubit.startPlayFromIndex(1);

    // A stuck "playing" flag would also silence the tap sound effects.
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.isPaused, isFalse);
    expect(cubit.state.isDelayingBetweenZikr, isFalse);
    expect(cubit.state.currentIndex, 1);
  });

  test("a zikr that is already done is skipped using the live count", () async {
    await cubit.saveSettings(delayType: AudioDelayTypeEnum.none);
    cubit.getActiveZikrCount = (index) => index == 0 ? 0 : 1;
    var done = 0;
    cubit.onDonePlaying = (_) => done++;

    await cubit.startPlayFromIndex(0);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Zikr 0 was already completed, so it is not played; the chain moved on to the
    // zikr without audio and stopped there.
    expect(done, 1);
    expect(cubit.state.currentIndex, 1);
    expect(cubit.state.isPlaying, isFalse);
  });

  test("pausing during the wait between repeats ends it, so resuming plays once", () async {
    await cubit.saveSettings(delayType: AudioDelayTypeEnum.fixedTime, delayDuration: 1);
    cubit.getActiveZikrCount = (_) => 3;
    cubit.onDonePlaying = (_) {};

    await cubit.startPlayFromIndex(0);
    expect(player.playedSources.length, 1);

    // The clip ends; the cubit now waits one second before the next repeat.
    player.complete.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.isDelayingBetweenZikr, isTrue);

    await cubit.pause();
    expect(cubit.state.isDelayingBetweenZikr, isFalse);
    await cubit.resume();
    expect(player.playedSources.length, 2);

    // The abandoned wait ends later and must not start a third playback.
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(player.playedSources.length, 2);
  });
}
