import 'dart:math';

import 'package:flutter/material.dart';

/// Height of the card and size of the zikr text on it.
class ShareCardLayout {
  final double height;
  final double mainFontSize;

  const ShareCardLayout({required this.height, required this.mainFontSize});
}

/// Works out how tall the shared image is and how big its zikr text is, so that the
/// whole zikr is always shown:
///
/// 1. A zikr that fits keeps the requested size and gets the biggest text that fits.
/// 2. A longer one makes the image taller, so the text can stay at
///    [minReadableFontSize].
/// 3. The image is never taller than [maxAspectRatio] times its width (2:3). Past that,
///    the text gets smaller, only as much as needed, instead of being cut.
///
/// A zikr that is too long for one image is split into pages before this; each page
/// is laid out on its own.
///
/// The numbers mirror the layout of `ShareableImageCard` (frame, paddings and gaps);
/// change them together.
class ShareCardMetrics {
  ShareCardMetrics._();

  /// Size the zikr text keeps while the image can still grow. At the usual 1080 px
  /// wide image this is about 18 logical pixels on a phone.
  static const double minReadableFontSize = 54;

  /// Largest size of the zikr text.
  static const double maxFontSize = 150;

  /// Smallest size the text is ever shrunk to.
  static const double floorFontSize = 12;

  /// Tallest image, as height divided by width: 3 / 2, a 2:3 portrait.
  static const double maxAspectRatio = 1.5;

  // Frame and padding of the card (see ShareableImageCard).
  static const double _frame = 36;
  static const double _frameGap = 12;
  static const double _sidePadding = 48;
  static const double _topPadding = 44;
  static const double _bottomPadding = 32;

  /// Fadl and source are cut with an ellipsis past these, so they can never take the
  /// room the zikr text needs. Real fadl texts are far shorter.
  static const int fadlMaxLines = 12;
  static const int sourceMaxLines = 4;

  /// Room left for rounding of line heights.
  static const double _slack = 12;

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

  static double _mainHeight(String text, TextStyle style, double fontSize, double width) {
    return _layout(
      TextSpan(
        text: text,
        style: style.copyWith(fontSize: fontSize),
      ),
      maxWidth: width,
    ).height;
  }

  /// The biggest font size in [low]..[high] at which the text is at most [maxHeight] tall.
  /// [low] when even that is too big.
  static double _largestFittingFont({
    required String text,
    required TextStyle style,
    required double width,
    required double maxHeight,
    required double low,
    required double high,
  }) {
    if (_mainHeight(text, style, high, width) <= maxHeight) return high;
    if (_mainHeight(text, style, low, width) > maxHeight) return low;

    var fits = low;
    var tooBig = high;
    for (var i = 0; i < 12 && tooBig - fits > .5; i++) {
      final middle = (fits + tooBig) / 2;
      if (_mainHeight(text, style, middle, width) <= maxHeight) {
        fits = middle;
      } else {
        tooBig = middle;
      }
    }
    return fits;
  }

  /// Everything on the card except the zikr text.
  static double _overhead({
    required double imageWidth,
    required String title,
    required TextStyle titleStyle,
    required TextStyle secondaryStyle,
    String? fadl,
    bool fadlLabel = true,
    String? source,
    int? count,
    bool hasDots = false,
  }) {
    final width = contentWidth(imageWidth);
    var height = 2 * (_frame + _frameGap) + _topPadding + _bottomPadding;

    // Title block: the title, then the ornament line.
    final titleHeight = _layout(
      TextSpan(text: title, style: titleStyle),
      maxWidth: width,
      maxLines: 2,
    ).height;
    height += titleHeight + 14 + 14 + 28;

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
              maxLines: fadlMaxLines,
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
                maxLines: sourceMaxLines,
              ).height;
        height += max(sourceHeight, pillHeight);
      }
    }

    // Gap above the footer, then the footer: rule, app name row, and the page dots of a
    // split zikr. The text region also has a 28 px gap under the title block (included).
    return height + 24 + 2 + 18 + 72 + (hasDots ? 10 + 20 : 0);
  }

  /// Height of the card and size of the zikr text for this content. The card is at least
  /// [minHeight] tall and at most [maxAspectRatio] times [imageWidth] (or [minHeight],
  /// when that is already taller).
  static ShareCardLayout layout({
    required double minHeight,
    required double imageWidth,
    required String title,
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
    final overhead =
        _overhead(
          imageWidth: imageWidth,
          title: title,
          titleStyle: titleStyle,
          secondaryStyle: secondaryStyle,
          fadl: fadl,
          fadlLabel: fadlLabel,
          source: source,
          count: count,
          hasDots: hasDots,
        ) +
        _slack;
    final maxHeight = max(minHeight, imageWidth * maxAspectRatio);

    // 1. Does the zikr fit the requested size with readable text?
    final fittingAtMin = _largestFittingFont(
      text: mainText,
      style: mainStyle,
      width: width,
      maxHeight: minHeight - overhead,
      low: floorFontSize,
      high: maxFontSize,
    );
    if (fittingAtMin >= minReadableFontSize) {
      return ShareCardLayout(height: minHeight, mainFontSize: fittingAtMin);
    }

    // 2. Grow the image so the text can stay readable, up to the tallest allowed.
    final neededAtReadable =
        overhead + _mainHeight(mainText, mainStyle, minReadableFontSize, width);
    if (neededAtReadable <= maxHeight) {
      return ShareCardLayout(height: neededAtReadable, mainFontSize: minReadableFontSize);
    }

    // 3. At the tallest image, shrink the text just enough to show all of it.
    final shrunk = _largestFittingFont(
      text: mainText,
      style: mainStyle,
      width: width,
      maxHeight: maxHeight - overhead,
      low: floorFontSize,
      high: minReadableFontSize,
    );
    return ShareCardLayout(height: maxHeight, mainFontSize: shrunk);
  }
}
