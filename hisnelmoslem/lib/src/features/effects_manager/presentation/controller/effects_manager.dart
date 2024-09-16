// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:vibration/vibration.dart';

class EffectsManager {
  final EffectsManagerRepo effectsManagerRepo;
  EffectsManager(this.effectsManagerRepo);

  ///
  final player = AudioPlayer();

  /// Play Sound

  Future<void> simulateTallySound() async {
    // player.play('sounds/tally_sound.mp3');
    await player.play(
      AssetSource('sounds/tally_sound.mp3'),
      volume: effectsManagerRepo.soundEffectVolume,
    );
  }

  Future<void> simulateZikrDoneSound() async {
    await player.play(
      AssetSource('sounds/zikr_done_sound.mp3'),
      volume: effectsManagerRepo.soundEffectVolume,
    );
  }

  Future simulateTransitionSound() async {}

  Future<void> simulateAllAzkarSoundFinished() async {
    await player.play(
      AssetSource('sounds/all_azkar_finished_sound.mp3'),
      volume: effectsManagerRepo.soundEffectVolume,
    );
  }

  /////////////////////
  /// Play vibration

  Future<void> simulateTallyVibrate() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!)
          {Vibration.vibrate(duration: 100)}
        else
          {HapticFeedback.lightImpact()},
      },
    );
  }

  Future<void> simulateZikrDoneVibrate() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!)
          {Vibration.vibrate(duration: 300)}
        else
          {HapticFeedback.mediumImpact()},
      },
    );
  }

  Future<void> simulateTransitionVibrate() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!)
          {Vibration.vibrate(duration: 25)}
        else
          {HapticFeedback.vibrate()},
      },
    );
  }

  Future<void> simulateAllAzkarVibrateFinished() async {
    await Vibration.hasCustomVibrationsSupport().then(
      (value) => {
        if (value!) {Vibration.vibrate()} else {HapticFeedback.heavyImpact()},
      },
    );
  }

  //////////////////////////////
  Future playTallyEffects() async {
    if (effectsManagerRepo.isTallySoundAllowed) {
      await simulateTallySound();
    }
    if (effectsManagerRepo.isTallyVibrateAllowed) {
      await simulateTallyVibrate();
    }
  }

  Future playZikrDoneEffects() async {
    if (effectsManagerRepo.isZikrDoneSoundAllowed) {
      await simulateZikrDoneSound();
    }
    if (effectsManagerRepo.isZikrDoneVibrateAllowed) {
      await simulateZikrDoneVibrate();
    }
  }

  Future playTransitionEffects() async {
    if (effectsManagerRepo.isTransitionSoundAllowed) {
      await simulateTransitionSound();
    }
    if (effectsManagerRepo.isTransitionVibrateAllowed) {
      await simulateTransitionVibrate();
    }
  }

  Future playAllAzkarFinishedEffects() async {
    if (effectsManagerRepo.isAllAzkarFinishedSoundAllowed) {
      await simulateAllAzkarSoundFinished();
    }
    if (effectsManagerRepo.isAllAzkarFinishedVibrateAllowed) {
      await simulateAllAzkarVibrateFinished();
    }
  }
}
