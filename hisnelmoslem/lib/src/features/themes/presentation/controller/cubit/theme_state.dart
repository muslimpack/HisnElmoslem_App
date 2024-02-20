// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final Color color;
  final Brightness brightness;
  final bool useMaterial3;
  final bool useOldTheme;
  final String fontFamily;
  const ThemeState({
    required this.color,
    required this.brightness,
    required this.useMaterial3,
    required this.useOldTheme,
    required this.fontFamily,
  });

  ThemeData themeData() {
    if (useOldTheme) {
      return ThemeData(
        useMaterial3: useMaterial3,
        brightness: brightness,
        colorSchemeSeed: color,
        fontFamily: fontFamily,
      );
    }
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: brightness,
      ),
      useMaterial3: useMaterial3,
      fontFamily: fontFamily,
    );
  }

  @override
  List<Object?> get props {
    return [color, brightness, useMaterial3, useOldTheme, fontFamily];
  }

  ThemeState copyWith({
    Color? color,
    Brightness? brightness,
    bool? useMaterial3,
    bool? useOldTheme,
    String? fontFamily,
  }) {
    return ThemeState(
      color: color ?? this.color,
      brightness: brightness ?? this.brightness,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      useOldTheme: useOldTheme ?? this.useOldTheme,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
