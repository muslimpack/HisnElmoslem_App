/// How sharp the exported picture is. The card is laid out 1080 logical pixels wide, so
/// the ratio is also the width in pixels divided by 1080.
enum ShareExportQuality {
  /// 1080 px wide: what chat and social apps show anyway. About 0.75 MB as a PNG.
  standard(1),

  /// 1620 px wide: sharp on any phone. About 1.4 MB.
  high(1.5),

  /// 2160 px wide, for printing or zooming. About 2.3 MB and slower to create.
  max(2);

  /// Pixels in the picture per logical pixel of the card.
  final double pixelRatio;

  const ShareExportQuality(this.pixelRatio);

  static ShareExportQuality fromName(String? name) {
    return ShareExportQuality.values.where((e) => e.name == name).firstOrNull ??
        ShareExportQuality.high;
  }
}
