// Fakes and builders shared by the tally tests.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeBox extends Fake implements GetStorage {
  final values = <String, dynamic>{};

  @override
  T? read<T>(String key) => values[key] as T?;

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;
}

class FakeEffects extends Fake implements EffectsManager {
  final completed = <bool>[];

  @override
  Future<void> playProgressEffects({
    bool zikrCompleted = false,
    bool titleCompleted = false,
  }) async {
    completed.add(zikrCompleted);
  }
}

class FakeVolume extends Fake implements VolumeButtonManager {
  @override
  Stream<VolumeButtonEvent> get stream => const Stream.empty();

  @override
  Future<void> toggleActivation({required bool activate}) async {}

  @override
  void dispose() {}
}

DbTally makeTally(
  String title, {
  int count = 0,
  int cycle = 33,
  bool active = false,
  String audio = "",
}) {
  final now = DateTime(2026);
  return DbTally(
    title: title,
    count: count,
    countReset: cycle,
    isActivated: active,
    created: now,
    lastUpdate: now,
    audioFile: audio,
  );
}

Future<Database> openMemoryDb() {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: TallyDatabaseHelper.dbVersion,
      onCreate: (db, _) => TallyDatabaseHelper.createSchema(db),
    ),
  );
}
