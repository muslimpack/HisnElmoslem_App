import 'package:equatable/equatable.dart';

class QuranPage extends Equatable {
  final String image;
  final int pageNumber;

  const QuranPage({
    required this.image,
    required this.pageNumber,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) => QuranPage(
        image: json["image"] as String,
        pageNumber: json["pageNumber"] as int,
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "pageNumber": pageNumber,
      };

  @override
  List<Object?> get props => [image, pageNumber];
}
