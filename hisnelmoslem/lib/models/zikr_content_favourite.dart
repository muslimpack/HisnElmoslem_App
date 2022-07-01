class DbContentFavourite {
  int id;
  int contentId;
  bool favourite;

  DbContentFavourite({
    this.id = 0,
    this.contentId = 0,
    this.favourite = false,
  });

  factory DbContentFavourite.fromMap(Map<String, dynamic> map) {
    return DbContentFavourite(
      id: map['_id'],
      contentId: map['content_id'],
      favourite: (map['favourite'] ?? 0) == 0 ? false : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'content_id': contentId,
      'favourite': favourite,
    };
  }

  @override
  String toString() {
    return ''''_id': $id |'content_id': $contentId |'favourite': $favourite''';
  }
}
