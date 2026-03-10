// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:vibration/vibration.dart';

class EffectsManager {
  final _player = AudioPlayer(playerId: "effectsManagerPlayer");

  final EffectsManagerRepo _effectsManagerRepo;
  final ZikrAudioPlayerCubit _zikrAudioPlayerCubit;

  DateTime _lastVibrationTime = DateTime.fromMillisecondsSinceEpoch(0);

  EffectsManager(this._effectsManagerRepo, this._zikrAudioPlayerCubit);

  ///MARK: Play Sound

  Future _playSound(AssetSource source) async {
    try {
      if (_zikrAudioPlayerCubit.state.isPlaying) return;
      hisnPrint(_player.playerId);
      await _player.stop();
      await _player.setVolume(_effectsManagerRepo.soundEffectVolume);
      await _player.play(source);
    } catch (e) {
      hisnPrint(e);
    }
  }

  Future<void> playPraiseSound() async {
    await _playSound(AssetSource('sounds/tally_sound.mp3'));
  }

  Future<void> playZikrSound() async {
    await _playSound(AssetSource('sounds/zikr_done_sound.mp3'));
  }

  Future<void> playTitleSound() async {
    await _playSound(AssetSource('sounds/all_azkar_finished_sound.mp3'));
  }

  ///MARK: Play vibration

  bool _canVibrate() {
    final now = DateTime.now();
    if (now.difference(_lastVibrationTime).inMilliseconds > 100) {
      _lastVibrationTime = now;
      return true;
    }
    return false;
  }

  Future<void> playPraiseVibratation() async {
    if (!_canVibrate()) return;
    final value = await Vibration.hasCustomVibrationsSupport();

    if (value) {
      await Vibration.vibrate(
        duration: _effectsManagerRepo.praiseVibrationDuration,
      );
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> playZikrVibratation() async {
    if (!_canVibrate()) return;
    final value = await Vibration.hasCustomVibrationsSupport();

    if (value) {
      await Vibration.vibrate(
        duration: _effectsManagerRepo.zikrVibrationDuration,
      );
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> playTitleVibratation() async {
    if (!_canVibrate()) return;
    final value = await Vibration.hasCustomVibrationsSupport();

    if (value) {
      await Vibration.vibrate(
        duration: _effectsManagerRepo.titleVibrationDuration,
      );
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  //////////////////////////////
  Future playPraiseEffects() async {
    if (_effectsManagerRepo.isPraiseSoundAllowed) {
      await playPraiseSound();
    }
    if (_effectsManagerRepo.isPraiseVibrationAllowed) {
      await playPraiseVibratation();
    }
  }

  Future playZikrEffects() async {
    if (_effectsManagerRepo.isZikrSoundAllowed) {
      await playZikrSound();
    }
    if (_effectsManagerRepo.isZikrVibrationAllowed) {
      await playZikrVibratation();
    }
  }

  Future playTitleEffects() async {
    if (_effectsManagerRepo.isTitleSoundAllowed) {
      await playTitleSound();
    }
    if (_effectsManagerRepo.isTitleVibrationAllowed) {
      await playTitleVibratation();
    }
  }

  void dispose() {
    _player.dispose();
  }
}
