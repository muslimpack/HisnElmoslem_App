import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_const.dart';

/// Name of a preset; the visible name is looked up from localization.
enum SharePresetId {
  classicNight,
  emeraldNight,
  midnightGold,
  deepOcean,
  royalPurple,
  charcoalCoral,
  parchment,
  mintGarden,
  cleanWhite,
  roseDawn,
  skyMorning,
}

/// Ready-made colors for the shared image: the background, the title/accent color and
/// the color of the zikr text.
class ShareColorPreset {
  final SharePresetId id;
  final Color background;
  final Color title;
  final Color text;

  const ShareColorPreset({
    required this.id,
    required this.background,
    required this.title,
    required this.text,
  });

  bool get isDark => background.computeLuminance() < 0.4;

  bool matches({required Color background, required Color title, required Color text}) {
    return this.background.toARGB32() == background.toARGB32() &&
        this.title.toARGB32() == title.toARGB32() &&
        this.text.toARGB32() == text.toARGB32();
  }

  /// WCAG contrast ratio between two colors (1 to 21).
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

const List<ShareColorPreset> kShareColorPresets = [
  // Dark
  ShareColorPreset(
    id: SharePresetId.classicNight,
    background: kShareImageBackgroundColor,
    title: kShareImageTitleTextColor,
    text: kShareImageAdditionalTextColor,
  ),
  ShareColorPreset(
    id: SharePresetId.emeraldNight,
    background: Color(0xFF0E1B18),
    title: Color(0xFF2EC4A6),
    text: Color(0xFFEAF7F2),
  ),
  ShareColorPreset(
    id: SharePresetId.midnightGold,
    background: Color(0xFF121826),
    title: Color(0xFFE5B64A),
    text: Color(0xFFFFF4D6),
  ),
  ShareColorPreset(
    id: SharePresetId.deepOcean,
    background: Color(0xFF0B1E2D),
    title: Color(0xFF4FC3F7),
    text: Color(0xFFE3F4FD),
  ),
  ShareColorPreset(
    id: SharePresetId.royalPurple,
    background: Color(0xFF1B1530),
    title: Color(0xFFB39DDB),
    text: Color(0xFFF1E9FF),
  ),
  ShareColorPreset(
    id: SharePresetId.charcoalCoral,
    background: Color(0xFF1E1E1E),
    title: Color(0xFFFF8A65),
    text: Color(0xFFF5F5F5),
  ),
  // Light
  ShareColorPreset(
    id: SharePresetId.parchment,
    background: Color(0xFFF6EEDC),
    title: Color(0xFF8B5E34),
    text: Color(0xFF3B2A1A),
  ),
  ShareColorPreset(
    id: SharePresetId.mintGarden,
    background: Color(0xFFEAF6F0),
    title: Color(0xFF1B7F5F),
    text: Color(0xFF173A2E),
  ),
  ShareColorPreset(
    id: SharePresetId.cleanWhite,
    background: Color(0xFFFFFFFF),
    title: Color(0xFF01797F),
    text: Color(0xFF222B33),
  ),
  ShareColorPreset(
    id: SharePresetId.roseDawn,
    background: Color(0xFFFCEEF0),
    title: Color(0xFFB5445A),
    text: Color(0xFF4A1F2A),
  ),
  ShareColorPreset(
    id: SharePresetId.skyMorning,
    background: Color(0xFFE8F1FB),
    title: Color(0xFF1E5FA8),
    text: Color(0xFF14283F),
  ),
];
