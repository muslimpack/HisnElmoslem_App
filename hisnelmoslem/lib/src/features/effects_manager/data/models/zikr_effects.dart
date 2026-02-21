// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ZikrEffects extends Equatable {
  final double soundEffectVolume;

  final bool soundEveryPraise;
  final bool soundEveryZikr;
  final bool soundEveryTitle;

  final bool vibrateEveryPraise;
  final bool vibrateEveryZikr;
  final bool vibrateEveryTitle;

  final int vibrateEveryPraiseDuration;
  final int vibrateEveryZikrDuration;
  final int vibrateEveryTitleDuration;

  const ZikrEffects({
    required this.soundEffectVolume,
    required this.soundEveryPraise,
    required this.soundEveryZikr,
    required this.soundEveryTitle,
    required this.vibrateEveryPraise,
    required this.vibrateEveryZikr,
    required this.vibrateEveryTitle,
    required this.vibrateEveryPraiseDuration,
    required this.vibrateEveryZikrDuration,
    required this.vibrateEveryTitleDuration,
  });

  ZikrEffects copyWith({
    double? soundEffectVolume,
    bool? soundEveryPraise,
    bool? soundEveryZikr,
    bool? soundEveryTitle,
    bool? vibrateEveryPraise,
    bool? vibrateEveryZikr,
    bool? vibrateEveryTitle,
    int? vibrateEveryPraiseDuration,
    int? vibrateEveryZikrDuration,
    int? vibrateEveryTitleDuration,
  }) {
    return ZikrEffects(
      soundEffectVolume: soundEffectVolume ?? this.soundEffectVolume,
      soundEveryPraise: soundEveryPraise ?? this.soundEveryPraise,
      soundEveryZikr: soundEveryZikr ?? this.soundEveryZikr,
      soundEveryTitle: soundEveryTitle ?? this.soundEveryTitle,
      vibrateEveryPraise: vibrateEveryPraise ?? this.vibrateEveryPraise,
      vibrateEveryZikr: vibrateEveryZikr ?? this.vibrateEveryZikr,
      vibrateEveryTitle: vibrateEveryTitle ?? this.vibrateEveryTitle,
      vibrateEveryPraiseDuration: vibrateEveryPraiseDuration ?? this.vibrateEveryPraiseDuration,
      vibrateEveryZikrDuration: vibrateEveryZikrDuration ?? this.vibrateEveryZikrDuration,
      vibrateEveryTitleDuration: vibrateEveryTitleDuration ?? this.vibrateEveryTitleDuration,
    );
  }

  @override
  List<Object> get props {
    return [
      soundEffectVolume,
      soundEveryPraise,
      soundEveryZikr,
      soundEveryTitle,
      vibrateEveryPraise,
      vibrateEveryZikr,
      vibrateEveryTitle,
      vibrateEveryPraiseDuration,
      vibrateEveryZikrDuration,
      vibrateEveryTitleDuration,
    ];
  }
}
