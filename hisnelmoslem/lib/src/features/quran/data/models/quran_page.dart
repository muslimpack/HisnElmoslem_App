class QuranPage {
  QuranPage({required this.image, required this.pageNumber});

  String image;
  int pageNumber;

  factory QuranPage.fromJson(Map<String, dynamic> json) => QuranPage(
        image: json["image"] as String,
        pageNumber: json["pageNumber"] as int,
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "pageNumber": pageNumber,
      };
}
