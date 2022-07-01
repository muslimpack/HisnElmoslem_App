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
    return DbTitleFavourite(
      id: map['_id'],
      titleId: map['title_id'],
      favourite: (map['favourite'] ?? 0) == 0 ? false : true,
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
    return ''''_id': $id |'title_id': $titleId |'favourite': $favourite''';
  }
}
