class Commentary {
  int id;
  int contentId;
  String sharh;
  String hadith;
  String benefit;

  Commentary({
    this.id = 0,
    this.sharh = "",
    this.contentId = 0,
    this.hadith = "",
    this.benefit = "",
  });

  factory Commentary.fromMap(Map<String, dynamic> map) {
    return Commentary(
      id: map['_id'],
      contentId: map['content_id'],
      sharh: (map['sharh'] as String).replaceAll("\\n", "\n"),
      hadith: ((map['hadith'] ?? "") as String).replaceAll("\\n", "\n"),
      benefit: ((map['benefit'] ?? "") as String).replaceAll("\\n", "\n"),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'content_id': contentId,
      'sharh': sharh,
      'hadith': hadith,
      'benefit': benefit,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
