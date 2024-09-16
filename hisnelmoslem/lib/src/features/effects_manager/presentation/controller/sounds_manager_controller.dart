import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:vibration/vibration.dart';

class EffectManager {
  ///
  final player = AudioPlayer();

  /// Play Sound

  Future<void> simulateTallySound() async {
    // player.play('sounds/tally_sound.mp3');
    await player.play(
      AssetSource('sounds/tally_sound.mp3'),
      volume: AppData.instance.soundEffectVolume,
    );
  }

  Future<void> simulateZikrDoneSound() async {
    await player.play(
      AssetSource('sounds/zikr_done_sound.mp3'),
      volume: AppData.instance.soundEffectVolume,
    );
  }

  Future simulateTransitionSound() async {}

  Future<void> simulateAllAzkarSoundFinished() async {
    await player.play(
      AssetSource('sounds/all_azkar_finished_sound.mp3'),
      volume: AppData.instance.soundEffectVolume,
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
    if (AppData.instance.isTallySoundAllowed) {
      await simulateTallySound();
    }
    if (AppData.instance.isTallyVibrateAllowed) {
      await simulateTallyVibrate();
    }
  }

  Future playZikrDoneEffects() async {
    if (AppData.instance.isZikrDoneSoundAllowed) {
      await simulateZikrDoneSound();
    }
    if (AppData.instance.isZikrDoneVibrateAllowed) {
      await simulateZikrDoneVibrate();
    }
  }

  Future playTransitionEffects() async {
    if (AppData.instance.isTransitionSoundAllowed) {
      await simulateTransitionSound();
    }
    if (AppData.instance.isTransitionVibrateAllowed) {
      await simulateTransitionVibrate();
    }
  }

  Future playAllAzkarFinishedEffects() async {
    if (AppData.instance.isAllAzkarFinishedSoundAllowed) {
      await simulateAllAzkarSoundFinished();
    }
    if (AppData.instance.isAllAzkarFinishedVibrateAllowed) {
      await simulateAllAzkarVibrateFinished();
    }
  }
}
