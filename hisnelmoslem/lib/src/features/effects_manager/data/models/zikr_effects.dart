// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ZikrEffects extends Equatable {
  final double soundEffectVolume;

  final bool isTallySoundAllowed;
  final bool isZikrDoneSoundAllowed;
  final bool isTransitionSoundAllowed;
  final bool isAllAzkarFinishedSoundAllowed;

  final bool isTallyVibrateAllowed;
  final bool isZikrDoneVibrateAllowed;
  final bool isTransitionVibrateAllowed;
  final bool isAllAzkarFinishedVibrateAllowed;

  const ZikrEffects({
    required this.soundEffectVolume,
    required this.isTallySoundAllowed,
    required this.isZikrDoneSoundAllowed,
    required this.isTransitionSoundAllowed,
    required this.isAllAzkarFinishedSoundAllowed,
    required this.isTallyVibrateAllowed,
    required this.isZikrDoneVibrateAllowed,
    required this.isTransitionVibrateAllowed,
    required this.isAllAzkarFinishedVibrateAllowed,
  });

  ZikrEffects copyWith({
    double? soundEffectVolume,
    bool? isTallySoundAllowed,
    bool? isZikrDoneSoundAllowed,
    bool? isTransitionSoundAllowed,
    bool? isAllAzkarFinishedSoundAllowed,
    bool? isTallyVibrateAllowed,
    bool? isZikrDoneVibrateAllowed,
    bool? isTransitionVibrateAllowed,
    bool? isAllAzkarFinishedVibrateAllowed,
  }) {
    return ZikrEffects(
      soundEffectVolume: soundEffectVolume ?? this.soundEffectVolume,
      isTallySoundAllowed: isTallySoundAllowed ?? this.isTallySoundAllowed,
      isZikrDoneSoundAllowed:
          isZikrDoneSoundAllowed ?? this.isZikrDoneSoundAllowed,
      isTransitionSoundAllowed:
          isTransitionSoundAllowed ?? this.isTransitionSoundAllowed,
      isAllAzkarFinishedSoundAllowed:
          isAllAzkarFinishedSoundAllowed ?? this.isAllAzkarFinishedSoundAllowed,
      isTallyVibrateAllowed:
          isTallyVibrateAllowed ?? this.isTallyVibrateAllowed,
      isZikrDoneVibrateAllowed:
          isZikrDoneVibrateAllowed ?? this.isZikrDoneVibrateAllowed,
      isTransitionVibrateAllowed:
          isTransitionVibrateAllowed ?? this.isTransitionVibrateAllowed,
      isAllAzkarFinishedVibrateAllowed: isAllAzkarFinishedVibrateAllowed ??
          this.isAllAzkarFinishedVibrateAllowed,
    );
  }

  @override
  List<Object> get props {
    return [
      soundEffectVolume,
      isTallySoundAllowed,
      isZikrDoneSoundAllowed,
      isTransitionSoundAllowed,
      isAllAzkarFinishedSoundAllowed,
      isTallyVibrateAllowed,
      isZikrDoneVibrateAllowed,
      isTransitionVibrateAllowed,
      isAllAzkarFinishedVibrateAllowed,
    ];
  }
}
