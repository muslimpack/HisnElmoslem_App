// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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
      removeDiacritics: removeDiacritics ?? this.removeDiacritics,
      imageWidth: imageWidth ?? this.imageWidth,
      imageQuality: imageQuality ?? this.imageQuality,
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
      showZikrIndex,
      removeDiacritics,
      imageWidth,
      imageQuality,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titleTextColor': titleTextColor.value,
      'bodyTextColor': bodyTextColor.value,
      'additionalTextColor': additionalTextColor.value,
      'backgroundColor': backgroundColor.value,
      'fontSize': fontSize,
      'showFadl': showFadl,
      'showSource': showSource,
      'showZikrIndex': showZikrIndex,
      'removeDiacritics': removeDiacritics,
      'imageWidth': imageWidth,
      'imageQuality': imageQuality,
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
      showZikrIndex: map['showZikrIndex'] as bool,
      removeDiacritics: map['removeDiacritics'] as bool,
      imageWidth: map['imageWidth'] as int,
      imageQuality: map['imageQuality'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShareImageSettings.fromJson(String source) =>
      ShareImageSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
