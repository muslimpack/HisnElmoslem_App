import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_advance_trigger.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_repo.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'tally_test_support.dart';

/// Stands in for the platform player; a test makes a playback finish with [finish].
class _FakePlayer extends Fake implements AudioPlayer {
  final complete = StreamController<void>.broadcast();
  final played = <String>[];

  void finish() => complete.add(null);

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
    played.add((source as DeviceFileSource).path.split(RegExp(r'[\\/]')).last);
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

void main() {
  setUpAll(sqfliteFfiInit);

  late Database db;
  late TallyDatabaseHelper helper;
  late FakeBox box;
  late TallyBloc bloc;
  late _FakePlayer player;
  late ZikrAudioPlayerCubit engine;
  late TallyAudioCubit audio;
  late Directory dir;
  late LocalCustomAudioStorage storage;
  late DateTime clock;
  late List<Duration> waits;

  Future<void> start(
    List<DbTally> counters, {
    TallyIterationMode mode = TallyIterationMode.none,
    TallyAdvanceTrigger trigger = TallyAdvanceTrigger.perCount,
    TallySessionLimit limit = const TallySessionLimit.endless(),
  }) async {
    db = await openMemoryDb();
    helper = TallyDatabaseHelper.withDatabase(db);
    box = FakeBox();
    dir = await Directory.systemTemp.createTemp('tally_audio_cubit_test');
    storage = LocalCustomAudioStorage(directoryOverride: dir);
    for (final c in counters) {
      await helper.addNewTally(dbTally: c);
      if (c.hasAudio) await File(await storage.pathFor(c.audioFile)).writeAsBytes([1]);
    }
    final repo = TallyRepo(box);
    await repo.saveIterationMode(mode);
    await repo.saveAdvanceTrigger(trigger);
    await repo.saveSessionLimit(limit);
    sl.registerLazySingleton(() => AppSettingsRepo(box));

    bloc = TallyBloc(helper, FakeEffects(), FakeVolume(), repo, storage);
    bloc.add(TallyStartEvent());
    await bloc.stream.firstWhere((s) => s is TallyLoadedState);

    player = _FakePlayer();
    engine = ZikrAudioPlayerCubit(ZikrAudioPlayerRepo(box), player: player);
    clock = DateTime(2026);
    waits = [];
    audio = TallyAudioCubit(
      tallyBloc: bloc,
      engine: engine,
      repo: repo,
      storage: storage,
      wait: (d) async => waits.add(d),
      now: () => clock,
    );
    await audio.init();
  }

  tearDown(() async {
    await audio.close();
    await bloc.close();
    await db.close();
    await sl.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  TallyLoadedState loaded() => bloc.state as TallyLoadedState;
  int countOf(String title) => loaded().allCounters.firstWhere((c) => c.title == title).count;
  String activeTitle() => loaded().activeCounter!.title;

  /// Waits until [condition] holds (the cubit works through a few async steps).
  Future<void> until(bool Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) fail('condition not reached in time');
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  /// Finishes the playback that is running and waits for the next one to start.
  Future<void> finishPlayback() async {
    final before = player.played.length;
    player.finish();
    await until(() => player.played.length > before || !audio.state.isActive);
  }

  group('without auto-advance', () {
    test('plays the active counter, counts once per playback and repeats it', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a'), makeTally('b', audio: 'b.m4a')]);

      await audio.start();
      expect(audio.state.phase, TallyAudioPhase.playing);
      expect(player.played, ['a.m4a']);

      await finishPlayback();
      await finishPlayback();

      expect(countOf('a'), 2);
      expect(countOf('b'), 0);
      expect(player.played, ['a.m4a', 'a.m4a', 'a.m4a']);
      expect(audio.state.sessionCount, 2);
      expect(audio.state.phase, TallyAudioPhase.playing, reason: 'endless by default');
    });
  });

  group('with auto-advance', () {
    test('per count: goes to the next counter after every playback', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a'), makeTally('b', audio: 'b.m4a')],
        mode: TallyIterationMode.circular,
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();
      await finishPlayback();

      expect(player.played, ['a.m4a', 'b.m4a', 'a.m4a', 'b.m4a']);
      expect(countOf('a'), 2);
      expect(countOf('b'), 1);
    });

    test('per cycle: keeps playing the same counter until its cycle is complete', () async {
      await start(
        [
          makeTally('a', active: true, cycle: 2, audio: 'a.m4a'),
          makeTally('b', cycle: 2, audio: 'b.m4a'),
        ],
        mode: TallyIterationMode.circular,
        trigger: TallyAdvanceTrigger.perCycle,
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();
      await finishPlayback();

      expect(player.played, ['a.m4a', 'a.m4a', 'b.m4a', 'b.m4a']);
      expect(countOf('a'), 2);
      expect(countOf('b'), 1);
    });

    test('skips counters that have no recording', () async {
      await start(
        [
          makeTally('a', active: true, audio: 'a.m4a'),
          makeTally('b'),
          makeTally('c', audio: 'c.m4a'),
        ],
        mode: TallyIterationMode.circular,
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();

      expect(player.played, ['a.m4a', 'c.m4a', 'a.m4a']);
      expect(countOf('b'), 0);
    });

    test('shuffle only ever picks other counters that have a recording', () async {
      await start(
        [
          makeTally('a', active: true, audio: 'a.m4a'),
          makeTally('b'),
          makeTally('c', audio: 'c.m4a'),
        ],
        mode: TallyIterationMode.shuffle,
      );

      await audio.start();
      for (var i = 0; i < 4; i++) {
        await finishPlayback();
      }

      expect(player.played, ['a.m4a', 'c.m4a', 'a.m4a', 'c.m4a', 'a.m4a']);
    });
  });

  group('limits', () {
    test('stops after the chosen number of counts', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a')],
        limit: const TallySessionLimit.count(3),
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();
      await finishPlayback();

      expect(audio.state.phase, TallyAudioPhase.idle);
      expect(audio.state.endedBecause, TallyAudioEnd.limitReached);
      expect(audio.state.sessionCount, 3);
      expect(countOf('a'), 3);
      expect(player.played.length, 3, reason: 'nothing is played after the limit');
    });

    test('stops once the chosen minutes of playing have passed', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a')],
        limit: const TallySessionLimit.minutes(10),
      );

      await audio.start();
      clock = clock.add(const Duration(minutes: 4));
      await finishPlayback();
      expect(audio.state.isActive, isTrue);

      clock = clock.add(const Duration(minutes: 7));
      await finishPlayback();
      expect(audio.state.endedBecause, TallyAudioEnd.limitReached);
      expect(countOf('a'), 2, reason: 'the playback that ran out the time still counts');
    });

    test('time spent paused does not count', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a')],
        limit: const TallySessionLimit.minutes(10),
      );

      await audio.start();
      clock = clock.add(const Duration(minutes: 6));
      await audio.pause();
      clock = clock.add(const Duration(hours: 2));
      await audio.resume();
      clock = clock.add(const Duration(minutes: 3));
      await finishPlayback();

      expect(audio.state.isActive, isTrue, reason: '9 minutes of playing so far');
    });

    test('the limit is saved', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);
      await audio.setLimit(const TallySessionLimit.minutes(15));
      expect(TallyRepo(box).getSessionLimit, const TallySessionLimit.minutes(15));
    });
  });

  group('controls', () {
    test('a counter without a recording does not start', () async {
      await start([makeTally('a', active: true)]);

      await audio.start();

      expect(player.played, isEmpty);
      expect(audio.state.phase, TallyAudioPhase.idle);
      expect(audio.state.endedBecause, TallyAudioEnd.noRecording);
    });

    test('a recording whose file is gone ends the session', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);
      await storage.delete('a.m4a');

      await audio.start();

      expect(player.played, isEmpty);
      expect(audio.state.endedBecause, TallyAudioEnd.noRecording);
    });

    test('pausing ignores a playback that finishes meanwhile, resuming starts it again', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);

      await audio.start();
      await audio.pause();
      player.finish();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(countOf('a'), 0);
      expect(audio.state.phase, TallyAudioPhase.paused);

      await audio.resume();
      expect(audio.state.phase, TallyAudioPhase.playing);
      expect(player.played, ['a.m4a', 'a.m4a']);
    });

    test('stop forgets the session', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);

      await audio.start();
      await finishPlayback();
      await audio.stop();

      expect(audio.state.phase, TallyAudioPhase.idle);
      expect(audio.state.sessionCount, 0);
      expect(countOf('a'), 1, reason: 'counts already made stay');

      player.finish();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(countOf('a'), 1, reason: 'a stopped session does not count');
    });

    test('the pause between playbacks follows the shared audio settings', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);
      await engine.saveSettings(delayType: AudioDelayTypeEnum.fixedTime, delayDuration: 4);

      await audio.start();
      await finishPlayback();

      expect(waits, [const Duration(seconds: 4)]);
      expect(activeTitle(), 'a');
    });

    test('with no pause set, playbacks follow each other directly', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a')]);
      await engine.saveSettings(delayType: AudioDelayTypeEnum.none);

      await audio.start();
      await finishPlayback();

      expect(waits, [Duration.zero]);
    });
  });

  group('summary and undo', () {
    test('a stopped session reports what it counted and how things were before', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a'), makeTally('b', audio: 'b.m4a')],
        mode: TallyIterationMode.circular,
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();
      await audio.stop();

      final summary = audio.state.summary!;
      expect(summary.counted, 2);
      expect(summary.before.map((c) => c.count), [0, 0]);
      expect(summary.activeBefore?.title, 'a');
    });

    test('undoing the summary puts the counts and the active counter back', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a'), makeTally('b', audio: 'b.m4a')],
        mode: TallyIterationMode.circular,
      );
      await audio.start();
      await finishPlayback();
      await finishPlayback();
      await audio.stop();
      expect(countOf('a'), 1);
      expect(countOf('b'), 1);

      final summary = audio.state.summary!;
      bloc.add(TallyRestoreCountersEvent(counters: summary.before));
      bloc.add(TallyToggleCounterActivationEvent(counter: summary.activeBefore!, activate: true));
      await until(() => countOf('a') == 0 && countOf('b') == 0 && activeTitle() == 'a');
    });

    test('a session that ends on its limit also has a summary', () async {
      await start(
        [makeTally('a', active: true, audio: 'a.m4a')],
        limit: const TallySessionLimit.count(2),
      );

      await audio.start();
      await finishPlayback();
      await finishPlayback();

      expect(audio.state.endedBecause, TallyAudioEnd.limitReached);
      expect(audio.state.summary?.counted, 2);
    });

    test(
      'stopping before anything was counted has no summary, and a new start clears the old one',
      () async {
        await start([makeTally('a', active: true, audio: 'a.m4a')]);

        await audio.start();
        await audio.stop();
        expect(audio.state.summary, isNull);

        await audio.start();
        await finishPlayback();
        await audio.stop();
        expect(audio.state.summary, isNotNull);

        await audio.start();
        expect(audio.state.summary, isNull);
      },
    );
  });
}
