import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/audio_preview_player.dart';

class AudioPreviewState extends Equatable {
  /// Which clip is loaded (see [AudioPreviewCubit.toggle]); null when idle.
  final String? activeKey;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPreviewState({
    this.activeKey,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioPreviewState copyWith({
    String? activeKey,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPreviewState(
      activeKey: activeKey ?? this.activeKey,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [activeKey, isPlaying, position, duration];
}

/// Lets several preview rows share one player: starting one clip stops the other.
class AudioPreviewCubit extends Cubit<AudioPreviewState> {
  final AudioPreviewPlayer player;

  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration> _durationSub;
  late final StreamSubscription<void> _completeSub;

  AudioPreviewCubit(this.player) : super(const AudioPreviewState()) {
    _positionSub = player.positionStream.listen((p) {
      if (!isClosed && state.activeKey != null) emit(state.copyWith(position: p));
    });
    _durationSub = player.durationStream.listen((d) {
      if (!isClosed && state.activeKey != null) emit(state.copyWith(duration: d));
    });
    _completeSub = player.completeStream.listen((_) {
      if (!isClosed) emit(const AudioPreviewState());
    });
  }

  /// Plays the clip, or pauses/resumes it when it is already the active one.
  /// Pass [filePath] for a recording or [asset] for a bundled original.
  Future<void> toggle(String key, {String? filePath, String? asset}) async {
    try {
      if (state.activeKey == key) {
        if (state.isPlaying) {
          await player.pause();
          emit(state.copyWith(isPlaying: false));
        } else {
          await player.resume();
          emit(state.copyWith(isPlaying: true));
        }
        return;
      }

      emit(AudioPreviewState(activeKey: key, isPlaying: true));
      await player.stop();
      await player.play(filePath: filePath, asset: asset);
    } catch (e) {
      hisnPrint('Preview error: $e');
      if (!isClosed) emit(const AudioPreviewState());
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await player.seek(position);
    } catch (e) {
      hisnPrint('Preview seek error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await player.stop();
    } catch (e) {
      hisnPrint('Preview stop error: $e');
    }
    if (!isClosed) emit(const AudioPreviewState());
  }

  @override
  Future<void> close() async {
    await _positionSub.cancel();
    await _durationSub.cancel();
    await _completeSub.cancel();
    await player.dispose();
    return super.close();
  }
}
