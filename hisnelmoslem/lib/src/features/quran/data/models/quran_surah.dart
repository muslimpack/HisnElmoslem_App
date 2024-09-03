import 'package:hisnelmoslem/src/features/quran/data/models/quran_page.dart';

class QuranSurah {
  QuranSurah({
    required this.surah,
    required this.pages,
  });

  String surah;
  List<QuranPage> pages;

  factory QuranSurah.fromJson(Map<String, dynamic> json) => QuranSurah(
        surah: json["surah"] as String,
        pages: List<QuranPage>.from(
          (json["pages"] as List)
              .map((x) => QuranPage.fromJson(x as Map<String, dynamic>)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "surah": surah,
        "pages": List<dynamic>.from(pages.map((x) => x.toJson())),
      };
}
