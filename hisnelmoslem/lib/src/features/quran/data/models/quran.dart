class Quran {
  Quran({
    required this.surah,
    required this.pages,
  });

  String surah;
  List<Page> pages;

  factory Quran.fromJson(Map<String, dynamic> json) => Quran(
        surah: json["surah"] as String,
        pages: List<Page>.from(
          (json["pages"] as List)
              .map((x) => Page.fromJson(x as Map<String, dynamic>)),
        ),
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
        image: json["image"] as String,
        pageNumber: json["pageNumber"] as int,
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "pageNumber": pageNumber,
      };
}
