// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class VerseRange extends Equatable {
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

  @override
  List<Object> get props => [startSura, startAyah, endingSura, endingAyah];
}
