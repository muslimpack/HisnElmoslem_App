/// Where a zikr comes from. The viewer encodes this in the title id; this enum is the
/// one place that reads that encoding, so nothing else has to guess from an id.
enum ZikrKind {
  /// From the bundled Hisn al-Muslim book (title ids >= 0).
  hisn,

  /// Written by the user (title ids <= -2, see `customViewerTitleId`).
  custom,

  /// The widespread-but-not-authentic hadith list (title id -1).
  fakeHadith;

  static const int fakeHadithTitleId = -1;

  /// The kind of the zikrs under the viewer title [titleId].
  static ZikrKind fromTitleId(int titleId) {
    if (titleId >= 0) return ZikrKind.hisn;
    if (titleId == fakeHadithTitleId) return ZikrKind.fakeHadith;
    return ZikrKind.custom;
  }
}
