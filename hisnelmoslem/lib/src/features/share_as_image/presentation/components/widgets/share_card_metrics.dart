import 'dart:math';

import 'package:flutter/material.dart';

/// Works out how tall the shared image has to be so the zikr text can be shown in full
/// at a readable size. A long zikr makes the image taller; its text is never shrunk
/// below [minReadableFontSize] or cut.
///
/// The numbers mirror the layout of `ShareableImageCard` (frame, paddings and gaps);
/// change them together.
class ShareCardMetrics {
  ShareCardMetrics._();

  /// Smallest size of the zikr text. At the usual 1080 px wide image this is about
  /// 18 logical pixels when it is viewed on a phone.
  static const double minReadableFontSize = 54;

  // Frame and padding of the card (see ShareableImageCard).
  static const double _frame = 36;
  static const double _frameGap = 12;
  static const double _sidePadding = 48;
  static const double _topPadding = 44;
  static const double _bottomPadding = 32;

  static const double badgeSize = 76;
  static const double badgeGap = 20;

  /// Width available to the content inside the two frames.
  static double contentWidth(double imageWidth) {
    return imageWidth - 2 * (_frame + _frameGap + _sidePadding);
  }

  static TextPainter _layout(InlineSpan span, {double maxWidth = double.infinity, int? maxLines}) {
    return TextPainter(
      text: span,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
  }

  /// Height of the whole card for this content, never below [minHeight].
  static double requiredHeight({
    required double minHeight,
    required double imageWidth,
    required String title,
    required bool hasNumber,
    required TextStyle titleStyle,
    required String mainText,
    required TextStyle mainStyle,
    required TextStyle secondaryStyle,
    String? fadl,
    bool fadlLabel = true,
    String? source,
    int? count,
    bool hasDots = false,
  }) {
    final width = contentWidth(imageWidth);
    var height = 2 * (_frame + _frameGap) + _topPadding + _bottomPadding;

    // Title block: the title (or the badge, when taller), then the ornament line.
    final titleWidth = hasNumber ? width - 2 * (badgeSize + badgeGap) : width;
    final titleHeight = _layout(
      TextSpan(text: title, style: titleStyle),
      maxWidth: titleWidth,
      maxLines: 2,
    ).height;
    height += max(titleHeight, hasNumber ? badgeSize : 0) + 14 + 14 + 28;

    // The zikr text at the smallest readable size.
    height += _layout(
      TextSpan(
        text: mainText,
        style: mainStyle.copyWith(fontSize: minReadableFontSize),
      ),
      maxWidth: width,
    ).height;

    // Fadl, source and count.
    final labelStyle = secondaryStyle.copyWith(fontWeight: FontWeight.bold);
    final smallStyle = secondaryStyle.copyWith(fontSize: (secondaryStyle.fontSize ?? 34) - 4);
    if (fadl != null || source != null || count != null) {
      height += 24;
      if (fadl != null) {
        // 32 + 24 padding at the sides of the text, 18 above and below.
        height +=
            _layout(
              TextSpan(
                children: [
                  if (fadlLabel) TextSpan(text: "الفضل: ", style: labelStyle),
                  TextSpan(text: fadl, style: secondaryStyle),
                ],
              ),
              maxWidth: width - 56,
            ).height +
            36;
      }
      if (source != null || count != null) {
        if (fadl != null) height += 14;

        var pillWidth = 0.0;
        var pillHeight = 0.0;
        if (count != null) {
          final pill = _layout(
            TextSpan(
              text: "عدد المرات: $count",
              style: smallStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          pillWidth = pill.width + 44 + 5 + 16;
          pillHeight = pill.height + 16 + 5;
        }
        final sourceHeight = source == null
            ? 0.0
            : _layout(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "المصدر: ",
                      style: smallStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: source, style: smallStyle),
                  ],
                ),
                maxWidth: width - pillWidth,
              ).height;
        height += max(sourceHeight, pillHeight);
      }
    }

    // Footer: rule, app name row, and the page dots of a split zikr.
    height += 24 + 2 + 18 + 72 + (hasDots ? 10 + 20 : 0);

    // A little slack for rounding of the line heights.
    return max(minHeight, height + 8);
  }
}
