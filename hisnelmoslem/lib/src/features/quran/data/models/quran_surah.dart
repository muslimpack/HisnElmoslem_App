// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/quran_page.dart';

class QuranSurah extends Equatable {
  final String surah;
  final List<QuranPage> pages;

  const QuranSurah({
    required this.surah,
    required this.pages,
  });

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

  @override
  List<Object> get props => [surah, pages];
}
