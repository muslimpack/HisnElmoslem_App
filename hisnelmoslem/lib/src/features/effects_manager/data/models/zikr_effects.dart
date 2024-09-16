// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ZikrEffects extends Equatable {
  final bool isTallySoundAllowed;
  final bool isZikrDoneSoundAllowed;
  final bool isTransitionSoundAllowed;

  final bool isAllAzkarFinishedSoundAllowed;
  final bool isZikrDoneVibrateAllowed;
  final bool isAllAzkarFinishedVibrateAllowed;

  final double soundEffectVolume;

  const ZikrEffects({
    required this.isTallySoundAllowed,
    required this.isZikrDoneSoundAllowed,
    required this.isTransitionSoundAllowed,
    required this.isAllAzkarFinishedSoundAllowed,
    required this.isZikrDoneVibrateAllowed,
    required this.isAllAzkarFinishedVibrateAllowed,
    required this.soundEffectVolume,
  });

  ZikrEffects copyWith({
    bool? isTallySoundAllowed,
    bool? isZikrDoneSoundAllowed,
    bool? isTransitionSoundAllowed,
    bool? isAllAzkarFinishedSoundAllowed,
    bool? isZikrDoneVibrateAllowed,
    bool? isAllAzkarFinishedVibrateAllowed,
    double? soundEffectVolume,
  }) {
    return ZikrEffects(
      isTallySoundAllowed: isTallySoundAllowed ?? this.isTallySoundAllowed,
      isZikrDoneSoundAllowed:
          isZikrDoneSoundAllowed ?? this.isZikrDoneSoundAllowed,
      isTransitionSoundAllowed:
          isTransitionSoundAllowed ?? this.isTransitionSoundAllowed,
      isAllAzkarFinishedSoundAllowed:
          isAllAzkarFinishedSoundAllowed ?? this.isAllAzkarFinishedSoundAllowed,
      isZikrDoneVibrateAllowed:
          isZikrDoneVibrateAllowed ?? this.isZikrDoneVibrateAllowed,
      isAllAzkarFinishedVibrateAllowed: isAllAzkarFinishedVibrateAllowed ??
          this.isAllAzkarFinishedVibrateAllowed,
      soundEffectVolume: soundEffectVolume ?? this.soundEffectVolume,
    );
  }

  @override
  List<Object> get props {
    return [
      isTallySoundAllowed,
      isZikrDoneSoundAllowed,
      isTransitionSoundAllowed,
      isAllAzkarFinishedSoundAllowed,
      isZikrDoneVibrateAllowed,
      isAllAzkarFinishedVibrateAllowed,
      soundEffectVolume,
    ];
  }
}
