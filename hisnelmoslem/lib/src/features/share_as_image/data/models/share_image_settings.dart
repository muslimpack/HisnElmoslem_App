// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';

class ShareImageSettings extends Equatable {
  final Color titleTextColor;
  final Color bodyTextColor;
  final Color additionalTextColor;
  final Color backgroundColor;
  final double fontSize;
  final bool showFadl;
  final bool showSource;
  final bool removeDiacritics;
  final ShareExportQuality exportQuality;

  const ShareImageSettings({
    required this.titleTextColor,
    required this.bodyTextColor,
    required this.additionalTextColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.showFadl,
    required this.showSource,
    required this.removeDiacritics,
    this.exportQuality = ShareExportQuality.high,
  });

  ShareImageSettings copyWith({
    Color? titleTextColor,
    Color? bodyTextColor,
    Color? additionalTextColor,
    Color? backgroundColor,
    double? fontSize,
    bool? showFadl,
    bool? showSource,
    bool? removeDiacritics,
    ShareExportQuality? exportQuality,
  }) {
    return ShareImageSettings(
      titleTextColor: titleTextColor ?? this.titleTextColor,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      additionalTextColor: additionalTextColor ?? this.additionalTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      showFadl: showFadl ?? this.showFadl,
      showSource: showSource ?? this.showSource,
      removeDiacritics: removeDiacritics ?? this.removeDiacritics,
      exportQuality: exportQuality ?? this.exportQuality,
    );
  }

  @override
  List<Object> get props {
    return [
      titleTextColor,
      bodyTextColor,
      additionalTextColor,
      backgroundColor,
      fontSize,
      showFadl,
      showSource,
      removeDiacritics,
      exportQuality,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titleTextColor': titleTextColor.toARGB32(),
      'bodyTextColor': bodyTextColor.toARGB32(),
      'additionalTextColor': additionalTextColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'fontSize': fontSize,
      'showFadl': showFadl,
      'showSource': showSource,
      'removeDiacritics': removeDiacritics,
      'exportQuality': exportQuality.name,
    };
  }

  factory ShareImageSettings.fromMap(Map<String, dynamic> map) {
    return ShareImageSettings(
      titleTextColor: Color(map['titleTextColor'] as int),
      bodyTextColor: Color(map['bodyTextColor'] as int),
      additionalTextColor: Color(map['additionalTextColor'] as int),
      backgroundColor: Color(map['backgroundColor'] as int),
      fontSize: map['fontSize'] as double,
      showFadl: map['showFadl'] as bool,
      showSource: map['showSource'] as bool,
      removeDiacritics: map['removeDiacritics'] as bool,
      // Saved before this setting existed: falls back to the default.
      exportQuality: ShareExportQuality.fromName(map['exportQuality'] as String?),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShareImageSettings.fromJson(String source) =>
      ShareImageSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
