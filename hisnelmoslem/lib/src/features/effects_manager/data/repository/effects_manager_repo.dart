import 'package:get_storage/get_storage.dart';

class EffectsManagerRepo {
  final GetStorage box;

  EffectsManagerRepo(this.box);

  ///MARK:Effects Sound
  /* ******* Effects ******* */

  ///
  static const _isTallySoundAllowedKey = 'tally_sound';
  bool get isTallySoundAllowed => box.read(_isTallySoundAllowedKey) ?? false;

  void changeTallySoundStatus({required bool value}) =>
      box.write(_isTallySoundAllowedKey, value);

  ///
  static const _isZikrDoneSoundAllowedKey = 'zikr_done_sound';
  bool get isZikrDoneSoundAllowed =>
      box.read(_isZikrDoneSoundAllowedKey) ?? false;

  void changeZikrDoneSoundStatus({required bool value}) =>
      box.write(_isZikrDoneSoundAllowedKey, value);

  ///
  static const _isTransitionSoundAllowedKey = 'tally_transition_sound';
  bool get isTransitionSoundAllowed =>
      box.read(_isTransitionSoundAllowedKey) ?? false;

  void changeTransitionSoundStatus({required bool value}) =>
      box.write(_isTransitionSoundAllowedKey, value);

  ///
  static const _isAllAzkarFinishedSoundAllowedKey = 'all_azkar_finished_sound';
  bool get isAllAzkarFinishedSoundAllowed =>
      box.read(_isAllAzkarFinishedSoundAllowedKey) ?? false;

  void changeAllAzkarFinishedSoundStatus({required bool value}) =>
      box.write(_isAllAzkarFinishedSoundAllowedKey, value);

  ///
  static const _soundEffectVolumeKey = 'soundEffectVolume';
  double get soundEffectVolume => box.read(_soundEffectVolumeKey) ?? 1;

  void changeSoundEffectVolume(double value) =>
      box.write(_soundEffectVolumeKey, value);

  ///MARK: Effect Vibration
  /* ******* Effects Vibration ******* */
  ///
  static const _isTallyVibrateAllowedKey = 'tally_vibrate';
  bool get isTallyVibrateAllowed =>
      box.read(_isTallyVibrateAllowedKey) ?? false;

  void changeTallyVibrateStatus({required bool value}) =>
      box.write(_isTallyVibrateAllowedKey, value);

  ///
  static const _isZikrDoneVibrateAllowedKey = 'zikr_done_vibrate';

  bool get isZikrDoneVibrateAllowed =>
      box.read(_isZikrDoneVibrateAllowedKey) ?? false;

  void changeZikrDoneVibrateStatus({required bool value}) =>
      box.write(_isZikrDoneVibrateAllowedKey, value);

  ///
  static const _isTransitionVibrateAllowedKey = 'tally_transition_vibrate';

  bool get isTransitionVibrateAllowed =>
      box.read(_isTransitionVibrateAllowedKey) ?? false;

  void changeTransitionVibrateStatus({required bool value}) =>
      box.write(_isTransitionVibrateAllowedKey, value);

  ///
  static const _isAllAzkarFinishedVibrateAllowedKey =
      "all_azkar_finished_vibrate";

  bool get isAllAzkarFinishedVibrateAllowed =>
      box.read(_isAllAzkarFinishedVibrateAllowedKey) ?? false;

  void changeAllAzkarFinishedVibrateStatus({required bool value}) =>
      box.write(_isAllAzkarFinishedVibrateAllowedKey, value);
}
