import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/audio_recorder_service.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/zikr_recorder/zikr_recorder_cubit.dart';

class FakeRecorder implements AudioRecorderService {
  bool permission = true;
  bool failOnStart = false;
  String? path;
  bool cancelled = false;
  final level = StreamController<double>.broadcast();

  @override
  Future<bool> ensurePermission() async => permission;

  @override
  Future<void> start(String path) async {
    if (failOnStart) throw StateError('no mic');
    this.path = path;
    File(path).writeAsBytesSync([1, 2, 3]);
  }

  @override
  Future<String?> stop() async => path;

  @override
  Future<void> cancel() async {
    cancelled = true;
    final p = path;
    if (p != null && File(p).existsSync()) File(p).deleteSync();
  }

  @override
  Stream<double> levels() => level.stream;

  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory dir;
  late LocalCustomAudioStorage storage;
  late FakeRecorder recorder;
  late ZikrRecorderCubit cubit;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('recorder_test');
    storage = LocalCustomAudioStorage(directoryOverride: dir);
    recorder = FakeRecorder();
    cubit = ZikrRecorderCubit(
      recorder: recorder,
      storage: storage,
      maxDuration: const Duration(seconds: 1),
    );
  });

  tearDown(() async {
    await cubit.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test("start then stop produces a take", () async {
    await cubit.start();
    expect(cubit.state.status, ZikrRecorderStatus.recording);

    recorder.level.add(0.5);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(cubit.state.elapsed, greaterThan(Duration.zero));
    expect(cubit.state.level, 0.5);

    await cubit.stop();
    expect(cubit.state.hasTake, isTrue);
    expect(await storage.exists(cubit.state.takeFileName!), isTrue);
  });

  test("denied permission is reported and nothing is recorded", () async {
    recorder.permission = false;
    await cubit.start();
    expect(cubit.state.status, ZikrRecorderStatus.permissionDenied);
    expect(recorder.path, isNull);
  });

  test("a recorder error ends in failed and leaves no file", () async {
    recorder.failOnStart = true;
    await cubit.start();
    expect(cubit.state.status, ZikrRecorderStatus.failed);
    expect(dir.listSync(), isEmpty);
  });

  test("discard removes the take", () async {
    await cubit.start();
    await cubit.stop();
    final file = cubit.state.takeFileName!;

    await cubit.discard();

    expect(cubit.state.status, ZikrRecorderStatus.idle);
    expect(await storage.exists(file), isFalse);
  });

  test("re-recording replaces the previous take", () async {
    await cubit.start();
    await cubit.stop();
    final first = cubit.state.takeFileName!;

    await cubit.start();
    await cubit.stop();

    expect(cubit.state.takeFileName, isNot(first));
    expect(await storage.exists(first), isFalse);
    expect(dir.listSync().length, 1);
  });

  test("recording stops by itself at the maximum length", () async {
    await cubit.start();
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    expect(cubit.state.status, ZikrRecorderStatus.recorded);
    expect(cubit.state.elapsed, const Duration(seconds: 1));
  });

  test("keepTake hands the file over so closing does not delete it", () async {
    await cubit.start();
    await cubit.stop();
    final file = cubit.keepTake()!;

    await cubit.close();

    expect(await storage.exists(file), isTrue);
  });

  test("closing while recording cancels and cleans up", () async {
    await cubit.start();
    await cubit.close();

    expect(recorder.cancelled, isTrue);
    expect(dir.listSync(), isEmpty);
  });
}
