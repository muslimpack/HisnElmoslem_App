import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final int sura;
  final int ayah;
  final String text;
  const Verse({
    required this.sura,
    required this.ayah,
    required this.text,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      sura: map['sura'] as int,
      ayah: map['ayah'] as int,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "sura": sura,
      "ayah": ayah,
      "text": text,
    };
  }

  @override
  List<Object> get props => [
        sura,
        ayah,
        text,
      ];

  Verse copyWith({
    int? sura,
    int? ayah,
    String? text,
  }) {
    return Verse(
      sura: sura ?? this.sura,
      ayah: ayah ?? this.ayah,
      text: text ?? this.text,
    );
  }
}
