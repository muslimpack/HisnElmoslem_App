import 'package:hisnelmoslem/src/core/models/bookmarked_item.dart';

class DbContentFavourite extends BookmarkedItem {
  const DbContentFavourite({
    required super.id,
    required super.itemId,
    required super.bookmarked,
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
      itemId: map['content_id'] as int,
      bookmarked: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'content_id': itemId,
      'favourite': bookmarked,
    };
  }
}
