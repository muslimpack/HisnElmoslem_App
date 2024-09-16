import 'package:get_storage/get_storage.dart';

class EffectsManagerRepo {
  final GetStorage box;

  EffectsManagerRepo(this.box);

  ///MARK:Effects Sound
  /* ******* Effects ******* */

  ///
  static const _soundEffectVolumeKey = 'soundEffectVolume';
  double get soundEffectVolume => box.read(_soundEffectVolumeKey) ?? 1;

  Future changeSoundEffectVolume(double value) =>
      box.write(_soundEffectVolumeKey, value);

  ///
  static const _isTallyPraiseAllowedKey = 'tally_sound';
  bool get isPraiseSoundAllowed => box.read(_isTallyPraiseAllowedKey) ?? false;

  Future changePraiseSoundStatus({required bool value}) =>
      box.write(_isTallyPraiseAllowedKey, value);

  ///
  static const _isZikrSoundAllowedKey = 'zikr_done_sound';
  bool get isZikrSoundAllowed => box.read(_isZikrSoundAllowedKey) ?? false;

  Future changeZikrSoundStatus({required bool value}) =>
      box.write(_isZikrSoundAllowedKey, value);

  ///
  static const _isTitleSoundAllowedKey = 'all_azkar_finished_sound';
  bool get isTitleSoundAllowed => box.read(_isTitleSoundAllowedKey) ?? false;

  Future changeTitleSoundStatus({required bool value}) =>
      box.write(_isTitleSoundAllowedKey, value);

  ///MARK: Effect Vibration
  /* ******* Effects Vibration ******* */
  ///
  static const _isPraiseVibrationAllowedKey = 'tally_vibrate';
  bool get isPraiseVibrationAllowed =>
      box.read(_isPraiseVibrationAllowedKey) ?? false;

  Future changePraiseVibrationStatus({required bool value}) =>
      box.write(_isPraiseVibrationAllowedKey, value);

  ///
  static const _isZikrVibrationAllowedKey = 'zikr_done_vibrate';

  bool get isZikrVibrationAllowed =>
      box.read(_isZikrVibrationAllowedKey) ?? false;

  Future changeZikrVibrationStatus({required bool value}) =>
      box.write(_isZikrVibrationAllowedKey, value);

  ///
  static const _isTitleVibrationAllowedKey = "all_azkar_finished_vibrate";

  bool get isTitleVibrationAllowed =>
      box.read(_isTitleVibrationAllowedKey) ?? false;

  Future changeTitleVibrationStatus({required bool value}) =>
      box.write(_isTitleVibrationAllowedKey, value);
}
