// To parse this JSON data, do
//
//     final hadith = hadithFromJson(jsonString);

import 'dart:convert';

List<Hadith> hadithFromJson(String str) => List<Hadith>.from(json.decode(str).map((x) => Hadith.fromJson(x)));

String hadithToJson(List<Hadith> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Hadith {
  Hadith({
    this.text,
    this.darga,
    this.source,
  });

  String text;
  String darga;
  String source;

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    text: json["text"],
    darga: json["darga"],
    source: json["source"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "darga": darga,
    "source": source,
  };
}
