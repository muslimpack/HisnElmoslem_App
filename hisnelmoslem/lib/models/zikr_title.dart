class DbTitle {
  int id;
  String name;
  int chapterId;
  int orderId;
  int favourite;

  DbTitle({
    this.id = 0,
    this.name = "",
    this.chapterId = 0,
    this.orderId = 0,
    this.favourite = 0,
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    return DbTitle(
      id: map['_id'],
      name: map['name'],
      chapterId: map['chapter_id'],
      orderId: map['order_id'],
      favourite: map['favourite'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'chapter_id': chapterId,
      'order_id': orderId,
      'favourite': favourite,
    };
  }

  @override
  String toString() {
    return '''
      '_id': $id,
      'name': $name,
      'chapter_id': $chapterId,
      'order_id': $orderId,
      'favourite': $favourite,
    ''';
  }
}
