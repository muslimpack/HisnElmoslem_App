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
  final AudioPlayer _player = AudioPlayer(playerId: "zikr_audio_player");
  final ZikrAudioPlayerRepo zikrAudioPlayerRepo;

  ZikrAudioPlayerCubit(this.zikrAudioPlayerRepo)
    : super(const ZikrAudioPlayerState());

  late Function(DbContent zikr)? onDonePlaying;
  StreamSubscription<void>? _completionSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  Future<void> init({
    Function(DbContent zikr)? onDonePlaying,
    List<DbContent>? zikrList,
  }) async {
    this.onDonePlaying = onDonePlaying;
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
      await Future.delayed(state.totalDuration);
    }
  }

  Future<void> _onPlaybackCompleted() async {
    emit(state.copyWith(position: Duration.zero));

    final currentZikr = state.currentZikr;
    if (currentZikr == null) return;

    onDonePlaying?.call(currentZikr);

    emit(
      state.copyWith(
        zikrList: List.of(state.zikrList)
          ..[state.currentIndex] = currentZikr.copyWith(
            count: currentZikr.count - 1,
          ),
      ),
    );

    if (state.currentZikr!.count > 0 &&
        state.repeatType == AudioRepeatTypeEnum.byZikrCount) {
      hisnPrint('count: ${state.currentZikr!.count}');
      await _handleDelayAndWait();
      if (!state.isPlaying || state.isPaused || isClosed) return;
      playZikrAt(state.currentIndex);
      return;
    }

    if (state.autoPlay) {
      await _handleDelayAndWait();
      if (!state.isPlaying || state.isPaused || isClosed) return;
      await _playNextZikr();
    }
  }

  Future<void> playZikrAt(int index) async {
    if (index < 0 || index >= state.zikrList.length) return;

    final zikr = state.zikrList[index];
    if (!zikr.hasAudio) return;

    if (zikr.count == 0) {
      emit(state.copyWith(currentIndex: index, isPlaying: true));
      _onPlaybackCompleted();
      return;
    }

    hisnPrint(_player.playerId);

    final audioPath = 'sounds/azkar/${zikr.audio}';
    final source = AssetSource(audioPath);

    await _player.stop();

    emit(
      state.copyWith(
        currentIndex: index,
        isPlaying: true,
        isPaused: false,
        position: Duration.zero,
      ),
    );

    await _player.play(source);
    await _player.setPlaybackRate(state.playbackSpeed);
    await _player.setVolume(state.volume);
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
    await playZikrAt(state.currentIndex);
  }

  Future<void> pause() async {
    await _player.pause();
    emit(state.copyWith(isPaused: true, isPlaying: false));
  }

  Future<void> resume() async {
    if (state.currentZikr != null && state.position > Duration.zero) {
      await _player.resume();
      emit(state.copyWith(isPaused: false, isPlaying: true));
    } else {
      await playAll();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    emit(
      state.copyWith(
        isPlaying: false,
        isPaused: false,
        position: Duration.zero,
      ),
    );
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
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
