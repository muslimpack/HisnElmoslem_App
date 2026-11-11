// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_repeat_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'zikr_audio_player_state.dart';

class ZikrAudioPlayerCubit extends Cubit<ZikrAudioPlayerState> {
  final AudioPlayer _player;
  final ZikrAudioPlayerRepo zikrAudioPlayerRepo;

  /// [player] is only given by tests.
  ZikrAudioPlayerCubit(this.zikrAudioPlayerRepo, {AudioPlayer? player})
    : _player = player ?? AudioPlayer(playerId: "zikr_audio_player"),
      super(const ZikrAudioPlayerState());

  Function(DbContent zikr)? onDonePlaying;
  int Function(int index)? getActiveZikrCount;

  /// Changes whenever playback is started, paused or stopped. A delay that was waiting
  /// when that happened sees a different value afterwards and ends without playing, so
  /// pausing and resuming during a delay can never start the next zikr twice.
  int _playbackToken = 0;

  StreamSubscription<void>? _completionSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  Future<void> init({
    Function(DbContent zikr)? onDonePlaying,
    int Function(int index)? getActiveZikrCount,
    List<DbContent>? zikrList,
  }) async {
    _playbackToken++;
    this.onDonePlaying = onDonePlaying;
    this.getActiveZikrCount = getActiveZikrCount;
    emit(
      state.copyWith(
        currentIndex: 0,
        isPlaying: false,
        autoPlay: true,
        playbackSpeed: zikrAudioPlayerRepo.getSpeed(),
        volume: zikrAudioPlayerRepo.getVolume(),
        delayType: zikrAudioPlayerRepo.getDelay(),
        delayDuration: zikrAudioPlayerRepo.getDelayDuration(),
        repeatType: zikrAudioPlayerRepo.getRepeat(),
        position: Duration.zero,
        totalDuration: Duration.zero,
        zikrList: zikrList,
      ),
    );

    try {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.speech,
          ),
          iOS: AudioContextIOS(
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
    } catch (e) {
      hisnPrint('AudioPlayer Error setting context: $e');
    }

    try {
      await _player.stop();
    } catch (e) {
      hisnPrint('AudioPlayer Error stopping in init: $e');
    }

    _completionSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();

    _completionSub = _player.onPlayerComplete.listen((_) async {
      await _onPlaybackCompleted();
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      if (!isClosed) emit(state.copyWith(position: p));
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      if (!isClosed) emit(state.copyWith(totalDuration: d));
    });
  }

  Future<void> saveSettings({
    double? speed,
    double? volume,
    AudioDelayTypeEnum? delayType,
    int? delayDuration,
    AudioRepeatTypeEnum? repeatType,
  }) async {
    zikrAudioPlayerRepo.saveSettings(
      speed: speed,
      volume: volume,
      delay: delayType,
      delayDuration: delayDuration,
      repeat: repeatType,
    );

    if (speed != null) {
      await _player.setPlaybackRate(speed);
      emit(state.copyWith(playbackSpeed: speed));
    }
    if (volume != null) {
      await _player.setVolume(volume);
      emit(state.copyWith(volume: volume));
    }
    if (delayType != null) {
      emit(state.copyWith(delayType: delayType));
    }
    if (delayDuration != null) {
      emit(state.copyWith(delayDuration: delayDuration));
    }
    if (repeatType != null) {
      emit(state.copyWith(repeatType: repeatType));
    }
  }

  Future<void> _handleDelayAndWait() async {
    if (state.delayType == AudioDelayTypeEnum.fixedTime) {
      await Future.delayed(Duration(seconds: state.delayDuration));
    } else if (state.delayType == AudioDelayTypeEnum.byPreviousZikr) {
      final int adjustedMilliseconds = (state.totalDuration.inMilliseconds / state.playbackSpeed)
          .round();
      await Future.delayed(Duration(milliseconds: adjustedMilliseconds));
    }
  }

  Future<void> _onPlaybackCompleted() async {
    emit(state.copyWith(position: Duration.zero));

    final currentZikr = state.currentZikr;
    final int token = _playbackToken;
    if (currentZikr == null) return;

    final int currentCount = getActiveZikrCount?.call(state.currentIndex) ?? currentZikr.count;

    if (currentCount > 1 && state.repeatType == AudioRepeatTypeEnum.byZikrCount) {
      hisnPrint('count: $currentCount');

      // Set delay state TRUE synchronously
      emit(state.copyWith(isDelayingBetweenZikr: true));

      // Notify Bloc to decrease count.
      // It won't turn page because count > 1.
      onDonePlaying?.call(currentZikr);

      await _handleDelayAndWait();

      // Paused, stopped or restarted while waiting: whoever did that already cleared
      // the delay flag, and this flow must not play anything.
      if (isClosed || token != _playbackToken) return;

      emit(state.copyWith(isDelayingBetweenZikr: false));
      playZikrAt(state.currentIndex);
      return;
    }

    if (state.autoPlay) {
      emit(state.copyWith(isDelayingBetweenZikr: true));

      // Decrease count in UI! This will make count 0.
      // The bloc will see `zikrAudioPlayerCubit.state.isDelayingBetweenZikr` is true,
      // preventing the immediate page turn.
      onDonePlaying?.call(currentZikr);

      await _handleDelayAndWait();

      if (isClosed || token != _playbackToken) return;

      emit(state.copyWith(isDelayingBetweenZikr: false));
      // By now, stream emits false. The bloc receives false and turns the page.

      await _playNextZikr();
    } else {
      // If no autoplay, just finish the zikr track.
      onDonePlaying?.call(currentZikr);
    }
  }

  Future<void> playZikrAt(int index) async {
    if (index < 0 || index >= state.zikrList.length) return;

    final zikr = state.zikrList[index];
    _playbackToken++;

    if (!zikr.hasPlayableAudio) {
      // Many azkar have no audio. Narration ends here; leaving it "playing" would keep
      // the audio bar busy and silence the tap sound effects until stopped by hand.
      try {
        await _player.stop();
      } catch (e) {
        hisnPrint('AudioPlayer Error stopping before a zikr without audio: $e');
      }
      emit(
        state.copyWith(
          currentIndex: index,
          isPlaying: false,
          isPaused: false,
          position: Duration.zero,
          totalDuration: Duration.zero,
          isDelayingBetweenZikr: false,
        ),
      );
      return;
    }

    // The list was copied when the viewer opened, so its counts are stale; ask for the
    // live count to skip azkar that are already done (e.g. restored session).
    final liveCount = getActiveZikrCount?.call(index) ?? zikr.count;
    if (liveCount == 0) {
      emit(state.copyWith(currentIndex: index, isPlaying: true, isDelayingBetweenZikr: false));
      _onPlaybackCompleted();
      return;
    }

    hisnPrint(_player.playerId);

    final Source source = zikr.userAudioPath.isNotEmpty
        ? DeviceFileSource(zikr.userAudioPath)
        : AssetSource('sounds/azkar/${zikr.audio}');

    try {
      await _player.stop();

      emit(
        state.copyWith(
          currentIndex: index,
          isPlaying: true,
          isPaused: false,
          position: Duration.zero,
          isDelayingBetweenZikr: false,
        ),
      );

      await _player.play(source, volume: state.volume);
      await _player.setPlaybackRate(state.playbackSpeed);
    } catch (e) {
      hisnPrint('AudioPlayer Error playing Zikr: $e');
      emit(state.copyWith(isPlaying: false, isPaused: false));
    }
  }

  Future<void> _playNextZikr() async {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.zikrList.length) {
      await playZikrAt(nextIndex);
    } else {
      emit(state.copyWith(isPlaying: false));
    }
  }

  Future<void> playAll() async {
    if (state.zikrList.isEmpty) return;
    try {
      await playZikrAt(state.currentIndex);
    } catch (e) {
      hisnPrint('AudioPlayer Error playAll: $e');
    }
  }

  Future<void> pause() async {
    _playbackToken++;
    try {
      await _player.pause();
      emit(state.copyWith(isPaused: true, isPlaying: false, isDelayingBetweenZikr: false));
    } catch (e) {
      hisnPrint('AudioPlayer Error pause: $e');
    }
  }

  Future<void> resume() async {
    if (state.currentZikr != null && state.position > Duration.zero) {
      try {
        await _player.resume();
        emit(state.copyWith(isPaused: false, isPlaying: true));
      } catch (e) {
        hisnPrint('AudioPlayer Error resume: $e');
      }
    } else {
      await playAll();
    }
  }

  Future<void> stop() async {
    _playbackToken++;
    try {
      await _player.stop();
      emit(
        state.copyWith(
          isPlaying: false,
          isPaused: false,
          position: Duration.zero,
          isDelayingBetweenZikr: false,
        ),
      );
    } catch (e) {
      hisnPrint('AudioPlayer Error stop: $e');
      emit(state.copyWith(isPlaying: false, isPaused: false, isDelayingBetweenZikr: false));
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      hisnPrint('AudioPlayer Error seek: $e');
    }
  }

  Future<void> skipToNextZikr() async {
    final nextIndex = min(state.currentIndex + 1, state.zikrList.length - 1);
    await playZikrAt(nextIndex);
  }

  Future<void> startPlayFromIndex(int index) async {
    await playZikrAt(index);
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
