class VerseRange {
  final int startSura;
  final int startAyah;
  final int endingSura;
  final int endingAyah;

  const VerseRange(
    this.startSura,
    this.startAyah,
    this.endingSura,
    this.endingAyah,
  );

  const VerseRange.same(
    this.startSura,
    this.startAyah,
  )   : endingSura = startSura,
        endingAyah = startAyah;

  bool isSingleVerse() {
    return startAyah == endingAyah && startSura == endingSura;
  }
}
