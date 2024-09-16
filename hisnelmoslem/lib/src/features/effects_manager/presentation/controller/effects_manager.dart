// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:vibration/vibration.dart';

class EffectsManager {
  final player = AudioPlayer();

  final EffectsManagerRepo _effectsManagerRepo;
  EffectsManager(this._effectsManagerRepo);

  ///MARK: Play Sound

  Future<void> playPraiseSound() async {
    await player.play(
      AssetSource('sounds/tally_sound.mp3'),
      volume: _effectsManagerRepo.soundEffectVolume,
    );
  }

  Future<void> playZikrSound() async {
    await player.play(
      AssetSource('sounds/zikr_done_sound.mp3'),
      volume: _effectsManagerRepo.soundEffectVolume,
    );
  }

  Future<void> playTitleSound() async {
    await player.play(
      AssetSource('sounds/all_azkar_finished_sound.mp3'),
      volume: _effectsManagerRepo.soundEffectVolume,
    );
  }

  /////////////////////
  ///MARK: Play vibration

  Future<void> playPraiseVibratation() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!)
          {Vibration.vibrate(duration: 100)}
        else
          {HapticFeedback.lightImpact()},
      },
    );
  }

  Future<void> playZikrVibratation() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!)
          {Vibration.vibrate(duration: 300)}
        else
          {HapticFeedback.mediumImpact()},
      },
    );
  }

  Future<void> playTitleVibratation() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!) {Vibration.vibrate()} else {HapticFeedback.heavyImpact()},
      },
    );
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
}
