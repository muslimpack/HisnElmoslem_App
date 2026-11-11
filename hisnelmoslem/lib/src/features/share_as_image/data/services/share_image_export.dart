import 'dart:math';
import 'dart:ui';

import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';

/// Rules for turning the card into a picture file.
abstract final class ShareImageExport {
  /// Longest side of the picture in pixels. Phones refuse to draw or encode bigger
  /// images (many GPUs stop at 4096), and a long zikr makes the card tall.
  static const double maxSidePixels = 4096;

  /// The pixel ratio to capture a card of [size] with. It is [quality]'s ratio, lowered
  /// when needed so the longest side stays within [maxSidePixels].
  static double pixelRatio(ShareExportQuality quality, Size size) {
    final longestSide = max(size.width, size.height);
    if (longestSide <= 0) return quality.pixelRatio;

    return min(quality.pixelRatio, maxSidePixels / longestSide);
  }

  /// File name for a page of a zikr, e.g. `Hisn-12_2_of_3-1700000000000.png`. Zikrs of
  /// a custom title have negative ids and get a `Custom` prefix.
  static String fileName({
    required int zikrId,
    required int pageIndex,
    required int pageCount,
    required DateTime time,
  }) {
    final prefix = zikrId < 0 ? "Custom-${zikrId.abs()}" : "Hisn-$zikrId";
    final pages = pageCount > 1 ? "_${pageIndex + 1}_of_$pageCount" : "";

    return "$prefix$pages-${time.millisecondsSinceEpoch}.png";
  }
}
