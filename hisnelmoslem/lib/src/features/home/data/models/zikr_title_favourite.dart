import 'package:hisnelmoslem/src/core/models/bookmarked_item.dart';

class DbTitleFavourite extends BookmarkedItem {
  const DbTitleFavourite({
    required super.id,
    required super.itemId,
    required super.bookmarked,
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
      itemId: map['title_id'] as int,
      bookmarked: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title_id': itemId,
      'favourite': bookmarked,
    };
  }
}
