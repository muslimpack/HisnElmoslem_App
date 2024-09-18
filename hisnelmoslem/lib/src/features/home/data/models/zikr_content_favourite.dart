class DbContentFavourite {
  final int id;
  final int contentId;
  final bool favourite;

  DbContentFavourite({
    required this.id,
    required this.contentId,
    required this.favourite,
  });

  factory DbContentFavourite.fromMap(Map<String, dynamic> map) {
    bool favourite;
    if ((map['favourite'] ?? 0) == 0) {
      favourite = false;
    } else {
      favourite = true;
    }
    return DbContentFavourite(
      id: map['_id'] as int,
      contentId: map['content_id'] as int,
      favourite: favourite,
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
    return toMap().toString();
  }
}
