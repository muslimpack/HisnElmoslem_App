// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'zikr_audio_player_state.dart';

class ZikrAudioPlayerCubit extends Cubit<ZikrAudioPlayerState> {
  final AudioPlayer _player = AudioPlayer(playerId: "zikr_audio_player");
  final ZikrAudioPlayerRepo zikrAudioPlayerRepo;

  ZikrAudioPlayerCubit(this.zikrAudioPlayerRepo) : super(const ZikrAudioPlayerState());

  late Function(DbContent zikr)? onDonePlaying;
  StreamSubscription<void>? _completionSub;

  Future<void> init({Function(DbContent zikr)? onDonePlaying, List<DbContent>? zikrList}) async {
    this.onDonePlaying = onDonePlaying;
    emit(
      state.copyWith(
        currentIndex: 0,
        isPlaying: false,
        autoPlay: true,
        playbackSpeed: zikrAudioPlayerRepo.getSpeed(),
        zikrList: zikrList,
      ),
    );

    _completionSub?.cancel();

    _completionSub = _player.onPlayerComplete.listen((_) async {
      await _onPlaybackCompleted();
    });
  }

  Future<void> saveSettings({double? speed}) async {
    zikrAudioPlayerRepo.saveSettings(speed: speed);
    emit(state.copyWith(playbackSpeed: speed));
  }

  Future<void> _onPlaybackCompleted() async {
    final currentZikr = state.currentZikr;
    if (currentZikr == null) return;

    onDonePlaying?.call(currentZikr);

    emit(
      state.copyWith(
        zikrList: List.of(state.zikrList)
          ..[state.currentIndex] = currentZikr.copyWith(count: currentZikr.count - 1),
      ),
    );

    if (state.currentZikr!.count > 0) {
      hisnPrint('count: ${state.currentZikr!.count}');
      playZikrAt(state.currentIndex);
      return;
    }

    if (state.autoPlay) {
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
    await _player.setPlaybackRate(state.playbackSpeed);

    emit(state.copyWith(currentIndex: index, isPlaying: true, isPaused: false));

    await _player.play(source);
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
    await _player.resume();
    emit(state.copyWith(isPaused: false, isPlaying: true));
  }

  Future<void> stop() async {
    await _player.stop();
    emit(state.copyWith(isPlaying: false, isPaused: false));
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
    await _player.dispose();
    return super.close();
  }
}
