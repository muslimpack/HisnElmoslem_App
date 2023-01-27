class DbTitleFavourite {
  int id;
  int titleId;
  bool favourite;

  DbTitleFavourite({
    this.id = 0,
    this.titleId = 0,
    this.favourite = false,
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
