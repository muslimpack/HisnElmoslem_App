part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final Color color;
  final Brightness deviceBrightness;
  final bool useMaterial3;
  final Color backgroundColor;
  final bool overrideBackgroundColor;
  final bool useOldTheme;
  final String fontFamily;
  final Locale? locale;
  final ThemeBrightnessModeEnum themeBrightnessMode;
  const ThemeState({
    required this.color,
    required this.deviceBrightness,
    required this.useMaterial3,
    required this.backgroundColor,
    required this.overrideBackgroundColor,
    required this.useOldTheme,
    required this.fontFamily,
    required this.locale,
    required this.themeBrightnessMode,
  });

  Brightness get appBrightness {
    switch (themeBrightnessMode) {
      case ThemeBrightnessModeEnum.system:
        return deviceBrightness;

      case ThemeBrightnessModeEnum.dark:
        return Brightness.dark;

      case ThemeBrightnessModeEnum.light:
        return Brightness.light;
    }
  }

  ThemeData get theme {
    if (useOldTheme && !useMaterial3) {
      return ThemeData(
        useMaterial3: false,
        brightness: appBrightness,
        colorSchemeSeed: color,
        fontFamily: fontFamily,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
    }
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: appBrightness,
        surface: overrideBackgroundColor ? backgroundColor : null,
      ),
      useMaterial3: useMaterial3,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeState copyWith({
    Color? color,
    Brightness? deviceBrightness,
    bool? useMaterial3,
    Color? backgroundColor,
    bool? overrideBackgroundColor,
    bool? useOldTheme,
    String? fontFamily,
    Locale? locale,
    ThemeBrightnessModeEnum? themeBrightnessMode,
  }) {
    return ThemeState(
      color: color ?? this.color,
      deviceBrightness: deviceBrightness ?? this.deviceBrightness,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overrideBackgroundColor:
          overrideBackgroundColor ?? this.overrideBackgroundColor,
      useOldTheme: useOldTheme ?? this.useOldTheme,
      fontFamily: fontFamily ?? this.fontFamily,
      locale: locale ?? this.locale,
      themeBrightnessMode: themeBrightnessMode ?? this.themeBrightnessMode,
    );
  }

  @override
  List<Object?> get props {
    return [
      color,
      deviceBrightness,
      useMaterial3,
      backgroundColor,
      overrideBackgroundColor,
      useOldTheme,
      fontFamily,
      locale,
      themeBrightnessMode,
    ];
  }
}
