import 'package:hisnelmoslem/src/core/models/bookmarked_item.dart';

class DbFakeHadithRead extends BookmarkedItem {
  const DbFakeHadithRead({
    required super.id,
    required super.itemId,
    required super.bookmarked,
  });

  factory DbFakeHadithRead.fromMap(Map<String, dynamic> map) {
    bool isRead;
    if ((map['isRead'] ?? 0) == 0) {
      isRead = false;
    } else {
      isRead = true;
    }
    return DbFakeHadithRead(
      id: map['_id'] as int,
      itemId: map['hadith_id'] as int,
      bookmarked: isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title_id': itemId,
      'isRead': bookmarked,
    };
  }
}
