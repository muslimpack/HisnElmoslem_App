part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ZikrEffects zikrEffects;
  final bool isCardReadMode;
  final bool enableWakeLock;
  final bool useHindiDigits;
  const SettingsState({
    required this.zikrEffects,
    required this.isCardReadMode,
    required this.enableWakeLock,
    required this.useHindiDigits,
  });

  @override
  List<Object> get props =>
      [zikrEffects, isCardReadMode, enableWakeLock, useHindiDigits];

  SettingsState copyWith({
    ZikrEffects? zikrEffects,
    bool? isCardReadMode,
    bool? enableWakeLock,
    bool? useHindiDigits,
  }) {
    return SettingsState(
      zikrEffects: zikrEffects ?? this.zikrEffects,
      isCardReadMode: isCardReadMode ?? this.isCardReadMode,
      enableWakeLock: enableWakeLock ?? this.enableWakeLock,
      useHindiDigits: useHindiDigits ?? this.useHindiDigits,
    );
  }
}
