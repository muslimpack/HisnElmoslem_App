import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_advance_trigger.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_repo.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'tally_test_support.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('DbTally', () {
    test('cycle helpers', () {
      final t = makeTally('a', count: 66);
      expect(t.cycles, 2);
      expect(t.countInCycle, 0);
      expect(t.isAtCycleEnd, isTrue);
      expect(makeTally('a', count: 40).isAtCycleEnd, isFalse);
      expect(makeTally('a').isAtCycleEnd, isFalse);
    });

    test('a zero or negative cycle size never divides by zero', () {
      final t = makeTally('a', count: 5, cycle: 0);
      expect(t.cycleSize, 1);
      expect(t.cycles, 5);
    });

    test('the trigger decides when auto-advance moves on', () {
      final first = makeTally('a', count: 1);
      expect(TallyAdvanceTrigger.perCount.shouldAdvance(first), isTrue);
      expect(TallyAdvanceTrigger.perCycle.shouldAdvance(first), isFalse);
      expect(TallyAdvanceTrigger.perCycle.shouldAdvance(first.copyWith(count: 33)), isTrue);
    });

    test('map round trip keeps the recording', () {
      final t = makeTally('a', audio: 'rec_1.m4a');
      final back = DbTally.fromMap({...t.toMap(), 'id': 7});
      expect(back.audioFile, 'rec_1.m4a');
      expect(back.hasAudio, isTrue);
    });

    test('old rows without the recording column read as having none', () {
      final back = DbTally.fromMap({
        'id': 1,
        'title': 'a',
        'count': 4,
        'countReset': 33,
        'isActivated': 0,
        'created': DateTime(2026).toString(),
        'lastUpdate': DateTime(2026).toString(),
      });
      expect(back.audioFile, '');
    });
  });

  group('database', () {
    test('upgrading a version 1 database keeps its rows and adds the recording column', () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('''
        CREATE TABLE data (
          id INTEGER NOT NULL UNIQUE, title TEXT, count INTEGER DEFAULT 0, created TEXT,
          lastUpdate TEXT, isActivated INTEGER DEFAULT 0, countReset INTEGER DEFAULT 33,
          description TEXT, PRIMARY KEY(id AUTOINCREMENT))
      ''');
      await db.insert('data', {
        'title': 'old',
        'count': 9,
        'created': DateTime(2026).toString(),
        'lastUpdate': DateTime(2026).toString(),
      });

      await TallyDatabaseHelper.upgradeSchema(db, 1);

      final helper = TallyDatabaseHelper.withDatabase(db);
      final all = await helper.getAllTally();
      expect(all.single.title, 'old');
      expect(all.single.count, 9);
      expect(all.single.audioFile, '');
      await db.close();
    });

    test('lists the recordings that counters refer to', () async {
      final db = await openMemoryDb();
      final helper = TallyDatabaseHelper.withDatabase(db);
      await helper.addNewTally(dbTally: makeTally('a', audio: 'one.m4a'));
      await helper.addNewTally(dbTally: makeTally('b'));
      await helper.addNewTally(dbTally: makeTally('c', audio: 'two.m4a'));

      expect(await helper.referencedAudioFiles(), {'one.m4a', 'two.m4a'});
      await db.close();
    });
  });

  group('pickNextCounter', () {
    final counters = [
      makeTally('a', active: true, audio: 'a.m4a'),
      makeTally('b'),
      makeTally('c', audio: 'c.m4a'),
    ].indexed.map((e) => e.$2.copyWith(id: e.$1 + 1)).toList();

    test('circular goes to the next one and wraps around', () {
      expect(
        TallyBloc.pickNextCounter(counters, TallyIterationMode.circular)?.title,
        'b',
      );
      final last = [
        counters[0].copyWith(isActivated: false),
        counters[1],
        counters[2].copyWith(isActivated: true),
      ];
      expect(TallyBloc.pickNextCounter(last, TallyIterationMode.circular)?.title, 'a');
    });

    test('audioOnly skips counters without a recording', () {
      expect(
        TallyBloc.pickNextCounter(counters, TallyIterationMode.circular, audioOnly: true)?.title,
        'c',
      );
    });

    test('none, a single counter, or no recording elsewhere means nowhere to go', () {
      expect(TallyBloc.pickNextCounter(counters, TallyIterationMode.none), isNull);
      expect(TallyBloc.pickNextCounter([counters.first], TallyIterationMode.circular), isNull);
      final onlyOne = [counters[0], counters[1].copyWith(audioFile: '')];
      expect(
        TallyBloc.pickNextCounter(onlyOne, TallyIterationMode.circular, audioOnly: true),
        isNull,
      );
    });

    test('shuffle never picks the active counter', () {
      for (var i = 0; i < 40; i++) {
        expect(
          TallyBloc.pickNextCounter(counters, TallyIterationMode.shuffle)?.isActivated,
          isFalse,
        );
      }
    });
  });

  group('TallyBloc counting', () {
    late Database db;
    late TallyDatabaseHelper helper;
    late FakeBox box;
    late FakeEffects effects;
    late TallyBloc bloc;
    late Directory audioDir;
    late LocalCustomAudioStorage storage;

    Future<void> start(
      List<DbTally> counters, {
      TallyIterationMode mode = TallyIterationMode.none,
      TallyAdvanceTrigger trigger = TallyAdvanceTrigger.perCount,
    }) async {
      db = await openMemoryDb();
      helper = TallyDatabaseHelper.withDatabase(db);
      for (final c in counters) {
        await helper.addNewTally(dbTally: c);
      }
      box = FakeBox();
      await TallyRepo(box).saveIterationMode(mode);
      await TallyRepo(box).saveAdvanceTrigger(trigger);
      sl.registerLazySingleton(() => AppSettingsRepo(box));
      effects = FakeEffects();
      audioDir = await Directory.systemTemp.createTemp('tally_audio_test');
      storage = LocalCustomAudioStorage(directoryOverride: audioDir);
      bloc = TallyBloc(helper, effects, FakeVolume(), TallyRepo(box), storage);
      bloc.add(TallyStartEvent());
      await bloc.stream.firstWhere((s) => s is TallyLoadedState);
    }

    tearDown(() async {
      await bloc.close();
      await db.close();
      await sl.reset();
      if (audioDir.existsSync()) audioDir.deleteSync(recursive: true);
    });

    TallyLoadedState loaded() => bloc.state as TallyLoadedState;

    Future<DbTally?> tap({bool audioOnly = false}) {
      final completer = Completer<DbTally?>();
      bloc.add(TallyIncreaseActiveCounterEvent(completer: completer, audioOnly: audioOnly));
      return completer.future;
    }

    test('without auto-advance the same counter keeps counting', () async {
      await start([makeTally('a', active: true), makeTally('b')]);
      await tap();
      final active = await tap();
      expect(active?.title, 'a');
      expect(active?.count, 2);
      expect(loaded().activeCounter?.count, 2);
    });

    test('per count: moves to the next counter after every count', () async {
      await start(
        [makeTally('a', active: true), makeTally('b')],
        mode: TallyIterationMode.circular,
      );
      final active = await tap();
      expect(active?.title, 'b');
      expect(loaded().allCounters.firstWhere((c) => c.title == 'a').count, 1);
      expect(loaded().allCounters.where((c) => c.isActivated).length, 1);
    });

    test('per cycle: stays on the counter until its cycle is complete', () async {
      await start(
        [
          makeTally('a', active: true, cycle: 3),
          makeTally('b'),
        ],
        mode: TallyIterationMode.circular,
        trigger: TallyAdvanceTrigger.perCycle,
      );
      expect((await tap())?.title, 'a');
      expect((await tap())?.title, 'a');
      final third = await tap();
      expect(third?.title, 'b');
      expect(loaded().allCounters.firstWhere((c) => c.title == 'a').count, 3);
    });

    test('each counter uses its own cycle size, also when auto-advance is on', () async {
      await start(
        [
          makeTally('a', active: true, cycle: 2),
          makeTally('b', cycle: 5),
        ],
        mode: TallyIterationMode.circular,
        trigger: TallyAdvanceTrigger.perCycle,
      );
      await tap();
      expect((await tap())?.title, 'b');
      expect(effects.completed, [false, true], reason: 'the second count closed the cycle');
    });

    test('audioOnly skips counters without a recording', () async {
      await start(
        [
          makeTally('a', active: true, audio: 'a.m4a'),
          makeTally('b'),
          makeTally('c', audio: 'c.m4a'),
        ],
        mode: TallyIterationMode.circular,
      );
      expect((await tap(audioOnly: true))?.title, 'c');
    });

    test('a single counter stays active when auto-advance has nowhere to go', () async {
      await start([makeTally('a', active: true)], mode: TallyIterationMode.shuffle);
      final active = await tap();
      expect(active?.title, 'a');
      expect(loaded().loadingIteration, isFalse);
    });

    test('changing the trigger is saved and used for the next count', () async {
      await start(
        [makeTally('a', active: true, cycle: 2), makeTally('b')],
        mode: TallyIterationMode.circular,
      );
      bloc.add(const TallySetAdvanceTriggerEvent(TallyAdvanceTrigger.perCycle));
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.advanceTrigger == TallyAdvanceTrigger.perCycle,
      );
      expect(TallyRepo(box).getAdvanceTrigger, TallyAdvanceTrigger.perCycle);

      expect((await tap())?.title, 'a');
      expect((await tap())?.title, 'b');
    });

    Future<File> recording(String name) async {
      final file = File(await storage.pathFor(name));
      await file.writeAsBytes([1, 2, 3]);
      return file;
    }

    test('deleting a counter removes its recording', () async {
      await start([makeTally('a', active: true, audio: 'a.m4a'), makeTally('b')]);
      final file = await recording('a.m4a');

      bloc.add(TallyDeleteCounterEvent(counter: loaded().allCounters.first));
      await bloc.stream.firstWhere((s) => s is TallyLoadedState && s.allCounters.length == 1);

      expect(file.existsSync(), isFalse);
    });

    test('replacing or removing a recording deletes the old file only', () async {
      await start([makeTally('a', active: true, audio: 'old.m4a')]);
      final old = await recording('old.m4a');
      final fresh = await recording('new.m4a');

      bloc.add(
        TallyEditCounterEvent(counter: loaded().allCounters.first.copyWith(audioFile: 'new.m4a')),
      );
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.allCounters.first.audioFile == 'new.m4a',
      );
      expect(old.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);

      bloc.add(TallyEditCounterEvent(counter: loaded().allCounters.first.copyWith(audioFile: '')));
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.allCounters.first.audioFile.isEmpty,
      );
      expect(fresh.existsSync(), isFalse);
    });

    test('editing a counter without touching the recording keeps it', () async {
      await start([makeTally('a', active: true, audio: 'keep.m4a')]);
      final file = await recording('keep.m4a');

      bloc.add(
        TallyEditCounterEvent(counter: loaded().allCounters.first.copyWith(title: 'renamed')),
      );
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.allCounters.first.title == 'renamed',
      );
      expect(file.existsSync(), isTrue);
    });

    test('the sweep of the custom azkar recordings keeps what counters use', () async {
      await start([makeTally('a', active: true, audio: 'used.m4a')]);
      final used = await recording('used.m4a');
      final other = await recording('other.m4a');
      final stray = await recording('stray.m4a');
      storage.addReferenceProvider(helper.referencedAudioFiles);

      await storage.deleteUnreferenced({'other.m4a'});

      expect(used.existsSync(), isTrue, reason: 'a counter uses it');
      expect(other.existsSync(), isTrue, reason: 'a custom zikr uses it');
      expect(stray.existsSync(), isFalse);

      // A restore replaces every recording, so counters do not protect files then.
      await storage.deleteUnreferenced(const {}, includeExternal: false);
      expect(used.existsSync(), isFalse);
    });

    test('reset can be undone', () async {
      await start([makeTally('a', active: true, count: 12), makeTally('b', count: 4)]);
      final before = loaded().allCounters;

      bloc.add(TallyResetAllCountersEvent());
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.allCounters.every((c) => c.count == 0),
      );

      bloc.add(TallyRestoreCountersEvent(counters: before));
      await bloc.stream.firstWhere(
        (s) => s is TallyLoadedState && s.allCounters.any((c) => c.count == 12),
      );
      expect(loaded().allCounters.map((c) => c.count), [12, 4]);
    });
  });
}
