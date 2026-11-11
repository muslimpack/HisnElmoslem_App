import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/effect_tier.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:vibration/vibration.dart';

/// Short sounds and vibrations for tapping a zikr, finishing a zikr and finishing a title.
class EffectsManager {
  final EffectsManagerRepo _repo;
  final ZikrAudioPlayerCubit _zikrAudioPlayerCubit;

  EffectsManager(this._repo, this._zikrAudioPlayerCubit);

  ///MARK: Sound

  /// Mix with whatever the user is listening to instead of taking audio focus, so a tap
  /// never pauses music or a recitation playing in another app.
  static final AudioContext _effectsContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();

  /// One player per sound, so playing one never reconfigures or cuts the others.
  final Map<EffectTier, AudioPlayer> _players = {};

  static const Map<EffectTier, String> _soundAssets = {
    EffectTier.praise: 'sounds/tally_sound.mp3',
    EffectTier.zikr: 'sounds/zikr_done_sound.mp3',
    EffectTier.title: 'sounds/all_azkar_finished_sound.mp3',
  };

  AudioPlayer _playerFor(EffectTier tier) {
    return _players.putIfAbsent(tier, () {
      final player = AudioPlayer(playerId: "effects_${tier.name}");
      player.setAudioContext(_effectsContext).catchError((Object e) => hisnPrint(e));
      return player;
    });
  }

  Future<void> _playSound(EffectTier tier) async {
    try {
      // The recited audio of the zikr has priority over effect sounds.
      if (_zikrAudioPlayerCubit.state.isPlaying) return;
      await _playerFor(tier).play(
        AssetSource(_soundAssets[tier]!),
        volume: _repo.soundEffectVolume,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      hisnPrint(e);
    }
  }

  Future<void> playPraiseSound() => _playSound(EffectTier.praise);
  Future<void> playZikrSound() => _playSound(EffectTier.zikr);
  Future<void> playTitleSound() => _playSound(EffectTier.title);

  ///MARK: Vibration

  /// Whether the vibration length chosen in the settings can be honoured. Asked once:
  /// the answer never changes and the platform call is slow.
  late final Future<bool> _hasCustomVibration = _queryCustomVibration();

  Future<bool> _queryCustomVibration() async {
    try {
      if (await Vibration.hasCustomVibrationsSupport()) return true;
      // Some Android phones report no "custom" support yet vibrate for a given length;
      // falling back to a fixed haptic tick there made the duration setting do nothing.
      return Platform.isAndroid && await Vibration.hasVibrator();
    } catch (e) {
      hisnPrint(e);
      return false;
    }
  }

  /// Held-down or rapid taps would queue vibrations; each kind is limited on its own so
  /// that finishing a zikr right after a tap still vibrates.
  final Map<EffectTier, DateTime> _lastVibration = {};

  bool _canVibrate(EffectTier tier) {
    final now = DateTime.now();
    final last = _lastVibration[tier];
    if (last != null && now.difference(last).inMilliseconds <= 100) return false;
    _lastVibration[tier] = now;
    return true;
  }

  int _vibrationDuration(EffectTier tier) => switch (tier) {
    EffectTier.praise => _repo.praiseVibrationDuration,
    EffectTier.zikr => _repo.zikrVibrationDuration,
    EffectTier.title => _repo.titleVibrationDuration,
  };

  Future<void> _vibrate(EffectTier tier) async {
    if (!_canVibrate(tier)) return;
    try {
      if (await _hasCustomVibration) {
        await Vibration.vibrate(duration: _vibrationDuration(tier));
      } else {
        await switch (tier) {
          EffectTier.praise => HapticFeedback.lightImpact(),
          EffectTier.zikr => HapticFeedback.mediumImpact(),
          EffectTier.title => HapticFeedback.heavyImpact(),
        };
      }
    } catch (e) {
      hisnPrint(e);
    }
  }

  Future<void> playPraiseVibratation() => _vibrate(EffectTier.praise);
  Future<void> playZikrVibratation() => _vibrate(EffectTier.zikr);
  Future<void> playTitleVibratation() => _vibrate(EffectTier.title);

  ///MARK: Per-tap effects

  bool _soundEnabled(EffectTier tier) => switch (tier) {
    EffectTier.praise => _repo.isPraiseSoundAllowed,
    EffectTier.zikr => _repo.isZikrSoundAllowed,
    EffectTier.title => _repo.isTitleSoundAllowed,
  };

  bool _vibrationEnabled(EffectTier tier) => switch (tier) {
    EffectTier.praise => _repo.isPraiseVibrationAllowed,
    EffectTier.zikr => _repo.isZikrVibrationAllowed,
    EffectTier.title => _repo.isTitleVibrationAllowed,
  };

  /// Plays the effects for one tap. Only the most significant enabled effect plays:
  /// the tap that finishes a title gives the title effect rather than a praise sound
  /// racing with it on the same player.
  Future<void> playProgressEffects({bool zikrCompleted = false, bool titleCompleted = false}) {
    final sound = pickEffectTier(
      zikrCompleted: zikrCompleted,
      titleCompleted: titleCompleted,
      isEnabled: _soundEnabled,
    );
    final vibration = pickEffectTier(
      zikrCompleted: zikrCompleted,
      titleCompleted: titleCompleted,
      isEnabled: _vibrationEnabled,
    );
    return Future.wait([
      if (sound != null) _playSound(sound),
      if (vibration != null) _vibrate(vibration),
    ]);
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
