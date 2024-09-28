// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ZikrEffects zikrEffects;
  final bool isCardReadMode;
  final bool enableWakeLock;
  final bool useHindiDigits;
  final double fontSize;
  final bool showDiacritics;
  final bool praiseWithVolumeKeys;
  final bool allowZikrSessionRestoration;
  const SettingsState({
    required this.zikrEffects,
    required this.isCardReadMode,
    required this.enableWakeLock,
    required this.useHindiDigits,
    required this.fontSize,
    required this.showDiacritics,
    required this.praiseWithVolumeKeys,
    required this.allowZikrSessionRestoration,
  });

  @override
  List<Object> get props {
    return [
      zikrEffects,
      isCardReadMode,
      enableWakeLock,
      useHindiDigits,
      fontSize,
      showDiacritics,
      praiseWithVolumeKeys,
      allowZikrSessionRestoration,
    ];
  }

  SettingsState copyWith({
    ZikrEffects? zikrEffects,
    bool? isCardReadMode,
    bool? enableWakeLock,
    bool? useHindiDigits,
    double? fontSize,
    bool? showDiacritics,
    bool? praiseWithVolumeKeys,
    bool? allowZikrSessionRestoration,
  }) {
    return SettingsState(
      zikrEffects: zikrEffects ?? this.zikrEffects,
      isCardReadMode: isCardReadMode ?? this.isCardReadMode,
      enableWakeLock: enableWakeLock ?? this.enableWakeLock,
      useHindiDigits: useHindiDigits ?? this.useHindiDigits,
      fontSize: fontSize ?? this.fontSize,
      showDiacritics: showDiacritics ?? this.showDiacritics,
      praiseWithVolumeKeys: praiseWithVolumeKeys ?? this.praiseWithVolumeKeys,
      allowZikrSessionRestoration:
          allowZikrSessionRestoration ?? this.allowZikrSessionRestoration,
    );
  }
}
