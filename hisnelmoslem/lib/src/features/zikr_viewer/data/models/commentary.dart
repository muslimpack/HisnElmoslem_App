// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class Commentary extends Equatable {
  final int id;
  final int contentId;
  final String sharh;
  final String hadith;
  final String benefit;

  const Commentary({
    required this.id,
    required this.sharh,
    required this.contentId,
    required this.hadith,
    required this.benefit,
  });

  factory Commentary.fromMap(Map<String, dynamic> map) {
    return Commentary(
      id: map['id'] as int,
      contentId: map['contentId'] as int,
      sharh: map['sharh'] as String? ?? "",
      hadith: map['hadith'] as String? ?? "",
      benefit: map['benefit'] as String? ?? "",
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      contentId,
      sharh,
      hadith,
      benefit,
    ];
  }
}
