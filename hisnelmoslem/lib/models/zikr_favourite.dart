class DbFavourite {
  int id;
  int contentId;
  int orderId;

  DbFavourite({
    this.id = 0,
    this.contentId = 0,
    this.orderId = 0,
  });

  factory DbFavourite.fromMap(Map<String, dynamic> map) {
    return DbFavourite(
      id: map['_id'],
      contentId: map['content_id'],
      orderId: map['order_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'content_id': contentId,
      'order_id': orderId,
    };
  }

  @override
  String toString() {
    return ''''_id': $id |'content_id': $contentId |'order_id': $orderId''';
  }
}
