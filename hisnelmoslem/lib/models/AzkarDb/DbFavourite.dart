class DbFavourite {
  final int id;
  final int contentId;
  final int orderId;

  DbFavourite({
    required this.id,
    required this.contentId,
    required this.orderId,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'content_id': contentId,
      'order_id': orderId,
    };
  }
}
