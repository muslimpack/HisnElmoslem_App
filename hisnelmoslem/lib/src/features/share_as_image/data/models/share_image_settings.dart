import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ShareImageSettings extends Equatable {
  final Color titleTextColor;
  final Color bodyTextColor;
  final Color additionalTextColor;
  final Color backgroundColor;
  final double fontSize;
  final bool showFadl;
  final bool showSource;
  final bool showZikrIndex;
  final bool fixedFont;
  final bool removeDiacritics;
  final int imageWidth;
  final double imageQuality;

  const ShareImageSettings({
    required this.titleTextColor,
    required this.bodyTextColor,
    required this.additionalTextColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.showFadl,
    required this.showSource,
    required this.showZikrIndex,
    required this.fixedFont,
    required this.removeDiacritics,
    required this.imageWidth,
    required this.imageQuality,
  });

  ShareImageSettings copyWith({
    Color? titleTextColor,
    Color? bodyTextColor,
    Color? additionalTextColor,
    Color? backgroundColor,
    double? fontSize,
    bool? showFadl,
    bool? showSource,
    bool? showZikrIndex,
    bool? fixedFont,
    bool? removeDiacritics,
    int? imageWidth,
    double? imageQuality,
  }) {
    return ShareImageSettings(
      titleTextColor: titleTextColor ?? this.titleTextColor,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      additionalTextColor: additionalTextColor ?? this.additionalTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      showFadl: showFadl ?? this.showFadl,
      showSource: showSource ?? this.showSource,
      showZikrIndex: showZikrIndex ?? this.showZikrIndex,
      fixedFont: fixedFont ?? this.fixedFont,
      removeDiacritics: removeDiacritics ?? this.removeDiacritics,
      imageWidth: imageWidth ?? this.imageWidth,
      imageQuality: imageQuality ?? this.imageQuality,
    );
  }

  @override
  List<Object?> get props => [
        titleTextColor,
        bodyTextColor,
        additionalTextColor,
        backgroundColor,
        fontSize,
        showFadl,
        showSource,
        showZikrIndex,
        fixedFont,
        removeDiacritics,
        imageWidth,
        imageQuality,
      ];
}
