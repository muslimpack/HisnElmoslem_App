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
  final bool ignoreNotificationPermission;
  final bool showAudioBar;
  const SettingsState({
    required this.zikrEffects,
    required this.isCardReadMode,
    required this.enableWakeLock,
    required this.useHindiDigits,
    required this.fontSize,
    required this.showDiacritics,
    required this.praiseWithVolumeKeys,
    required this.allowZikrSessionRestoration,
    required this.ignoreNotificationPermission,
    required this.showAudioBar,
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
      ignoreNotificationPermission,
      showAudioBar,
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
    bool? ignoreNotificationPermission,
    bool? showAudioBar,
  }) {
    return SettingsState(
      zikrEffects: zikrEffects ?? this.zikrEffects,
      isCardReadMode: isCardReadMode ?? this.isCardReadMode,
      enableWakeLock: enableWakeLock ?? this.enableWakeLock,
      useHindiDigits: useHindiDigits ?? this.useHindiDigits,
      fontSize: fontSize ?? this.fontSize,
      showDiacritics: showDiacritics ?? this.showDiacritics,
      praiseWithVolumeKeys: praiseWithVolumeKeys ?? this.praiseWithVolumeKeys,
      allowZikrSessionRestoration: allowZikrSessionRestoration ?? this.allowZikrSessionRestoration,
      ignoreNotificationPermission:
          ignoreNotificationPermission ?? this.ignoreNotificationPermission,
      showAudioBar: showAudioBar ?? this.showAudioBar,
    );
  }
}
