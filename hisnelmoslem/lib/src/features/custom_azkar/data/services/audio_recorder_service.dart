import 'dart:async';

import 'package:record/record.dart';

/// Thin wrapper over the platform recorder so the cubit can be tested without a microphone.
abstract interface class AudioRecorderService {
  /// Asks for the microphone permission when needed. False when the user refused.
  Future<bool> ensurePermission();

  /// Starts recording into [path] (AAC, mono).
  Future<void> start(String path);

  /// Stops and returns the written file path, or null when nothing was recorded.
  Future<String?> stop();

  /// Stops and discards what was recorded so far.
  Future<void> cancel();

  /// Input level while recording, from 0 (silence) to 1 (loud).
  Stream<double> levels();

  Future<void> dispose();
}

class RecordPackageAudioRecorder implements AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  /// Quiet speech sits around -45 dB, normal speech around -20 dB.
  static const double _floorDb = -50;

  @override
  Future<bool> ensurePermission() => _recorder.hasPermission();

  @override
  Future<void> start(String path) {
    return _recorder.start(
      const RecordConfig(
        bitRate: 64000,
        sampleRate: 22050,
      ),
      path: path,
    );
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Stream<double> levels() {
    return _recorder.onAmplitudeChanged(const Duration(milliseconds: 120)).map((a) {
      final db = a.current.isFinite ? a.current : _floorDb;
      return ((db - _floorDb) / -_floorDb).clamp(0.0, 1.0);
    });
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
