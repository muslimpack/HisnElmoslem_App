class VerseRange {
  final int startSura;
  final int startAyah;
  final int endingSura;
  final int endingAyah;
  final int versesInRange;

  const VerseRange(
    this.startSura,
    this.startAyah,
    this.endingSura,
    this.endingAyah,
    this.versesInRange,
  );

  const VerseRange.same(
    this.startSura,
    this.startAyah,
    this.versesInRange,
  )   : endingSura = startSura,
        endingAyah = startAyah;

  bool isSingleVerse() {
    return startAyah == endingAyah && startSura == endingSura;
  }
}
