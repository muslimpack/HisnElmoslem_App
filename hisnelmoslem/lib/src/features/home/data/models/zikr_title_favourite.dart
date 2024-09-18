class DbTitleFavourite {
  final int id;
  final int titleId;
  final bool favourite;

  DbTitleFavourite({
    required this.id,
    required this.titleId,
    required this.favourite,
  });

  factory DbTitleFavourite.fromMap(Map<String, dynamic> map) {
    bool favourite;
    if ((map['favourite'] ?? 0) == 0) {
      favourite = false;
    } else {
      favourite = true;
    }
    return DbTitleFavourite(
      id: map['_id'] as int,
      titleId: map['title_id'] as int,
      favourite: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title_id': titleId,
      'favourite': favourite,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
