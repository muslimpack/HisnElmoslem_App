// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ZikrEffects extends Equatable {
  final double soundEffectVolume;

  final bool isTallySoundAllowed;
  final bool soundEveryPraise;
  final bool soundEveryZikr;
  final bool soundEveryTitle;

  final bool isTallyVibrateAllowed;
  final bool vibrateEveryPraise;
  final bool vibrateEveryZikr;
  final bool vibrateEveryTitle;

  const ZikrEffects({
    required this.soundEffectVolume,
    required this.isTallySoundAllowed,
    required this.soundEveryPraise,
    required this.soundEveryZikr,
    required this.soundEveryTitle,
    required this.isTallyVibrateAllowed,
    required this.vibrateEveryPraise,
    required this.vibrateEveryZikr,
    required this.vibrateEveryTitle,
  });

  ZikrEffects copyWith({
    double? soundEffectVolume,
    bool? isTallySoundAllowed,
    bool? soundEveryPraise,
    bool? soundEveryZikr,
    bool? soundEveryTitle,
    bool? isTallyVibrateAllowed,
    bool? vibrateEveryPraise,
    bool? vibrateEveryZikr,
    bool? vibrateEveryTitle,
  }) {
    return ZikrEffects(
      soundEffectVolume: soundEffectVolume ?? this.soundEffectVolume,
      isTallySoundAllowed: isTallySoundAllowed ?? this.isTallySoundAllowed,
      soundEveryPraise: soundEveryPraise ?? this.soundEveryPraise,
      soundEveryZikr: soundEveryZikr ?? this.soundEveryZikr,
      soundEveryTitle: soundEveryTitle ?? this.soundEveryTitle,
      isTallyVibrateAllowed:
          isTallyVibrateAllowed ?? this.isTallyVibrateAllowed,
      vibrateEveryPraise: vibrateEveryPraise ?? this.vibrateEveryPraise,
      vibrateEveryZikr: vibrateEveryZikr ?? this.vibrateEveryZikr,
      vibrateEveryTitle: vibrateEveryTitle ?? this.vibrateEveryTitle,
    );
  }

  @override
  List<Object> get props {
    return [
      soundEffectVolume,
      isTallySoundAllowed,
      soundEveryPraise,
      soundEveryZikr,
      soundEveryTitle,
      isTallyVibrateAllowed,
      vibrateEveryPraise,
      vibrateEveryZikr,
      vibrateEveryTitle,
    ];
  }
}
