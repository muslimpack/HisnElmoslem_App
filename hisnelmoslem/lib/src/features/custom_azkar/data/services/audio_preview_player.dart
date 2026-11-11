import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Plays one clip at a time for the recording sheet (the user's take, an existing
/// recording or the bundled original). Kept behind an interface for tests.
abstract interface class AudioPreviewPlayer {
  /// Plays [filePath] (a recording) or, when null, the bundled [asset].
  Future<void> play({String? filePath, String? asset});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);

  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<void> get completeStream;

  Future<void> dispose();
}

class AudioplayersPreviewPlayer implements AudioPreviewPlayer {
  final AudioPlayer _player = AudioPlayer(playerId: "custom_audio_preview");

  @override
  Future<void> play({String? filePath, String? asset}) {
    final Source source = filePath != null
        ? DeviceFileSource(filePath)
        : AssetSource('sounds/azkar/$asset');
    return _player.play(source);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;

  @override
  Stream<Duration> get durationStream => _player.onDurationChanged;

  @override
  Stream<void> get completeStream => _player.onPlayerComplete;

  @override
  Future<void> dispose() => _player.dispose();
}
