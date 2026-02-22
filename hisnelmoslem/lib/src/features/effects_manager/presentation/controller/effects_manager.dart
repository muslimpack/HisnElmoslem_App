// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class EffectsManager {
  final AudioPlayer _player = AudioPlayer();

  final EffectsManagerRepo _effectsManagerRepo;
  EffectsManager(this._effectsManagerRepo) {
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.ambient,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.assistanceSonification,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: true,
        ),
      );
    } catch (e) {
      hisnPrint("Error initializing audio session: $e");
    }
  }

  ///MARK: Play Sound

  Future _playSound(String assetPath) async {
    try {
      hisnPrint("just_audio playing effect");
      await _player.stop();
      await _player.setVolume(_effectsManagerRepo.soundEffectVolume);
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      hisnPrint(e);
    }
  }

  Future<void> playPraiseSound() async {
    await _playSound('assets/sounds/tally_sound.mp3');
  }

  Future<void> playZikrSound() async {
    await _playSound('assets/sounds/zikr_done_sound.mp3');
  }

  Future<void> playTitleSound() async {
    await _playSound('assets/sounds/all_azkar_finished_sound.mp3');
  }

  ///MARK: Play vibration

  Future<void> playPraiseVibratation() async {
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
}
