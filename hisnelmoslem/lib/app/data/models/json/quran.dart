import 'dart:convert';

List<Quran> quranFromJson(String str) =>
    List<Quran>.from(json.decode(str).map((x) => Quran.fromJson(x)));

String quranToJson(List<Quran> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Quran {
  Quran({
    required this.surah,
    required this.pages,
  });

  String surah;
  List<Page> pages;

  factory Quran.fromJson(Map<String, dynamic> json) => Quran(
        surah: json["surah"],
        pages: List<Page>.from(json["pages"].map((x) => Page.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "surah": surah,
        "pages": List<dynamic>.from(pages.map((x) => x.toJson())),
      };
}

class Page {
  Page({required this.image, required this.pageNumber});

  String image;
  int pageNumber;

  factory Page.fromJson(Map<String, dynamic> json) => Page(
        image: json["image"],
        pageNumber: json["pageNumber"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "pageNumber": pageNumber,
      };
}
