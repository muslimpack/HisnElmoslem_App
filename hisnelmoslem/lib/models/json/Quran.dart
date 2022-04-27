import 'dart:convert';

List<Quran> quranFromJson(String str) =>
    List<Quran>.from(json.decode(str).map((x) => Quran.fromJson(x)));

String quranToJson(List<Quran> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Quran {
  Quran({
    required this.surha,
    required this.pages,
  });

  String surha;
  List<String> pages;

  factory Quran.fromJson(Map<String, dynamic> json) => Quran(
        surha: json["surha"],
        pages: List<String>.from(json["pages"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "surha": surha,
        "pages": List<dynamic>.from(pages.map((x) => x)),
      };
}
