class DbTitle {
  int id;
  String name;
  int chapterId;
  int orderId;
  bool favourite;

  DbTitle({
    this.id = 0,
    this.name = "",
    this.chapterId = 0,
    this.orderId = 0,
    this.favourite = false,
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    return DbTitle(
      id: map['_id'],
      name: map['name'],
      chapterId: map['chapter_id'],
      orderId: map['order_id'],
      favourite: map['favourite'] == 0 ? false : true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'chapter_id': chapterId,
      'order_id': orderId,
      'favourite': favourite ? 1 : 0,
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
