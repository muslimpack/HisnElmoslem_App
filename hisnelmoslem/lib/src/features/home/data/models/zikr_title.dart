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
    bool favourite;
    if ((map['favourite'] ?? 0) == 0) {
      favourite = false;
    } else {
      favourite = true;
    }
    return DbTitle(
      id: map['_id'] as int,
      name: map['name'] as String,
      chapterId: map['chapter_id'] as int,
      orderId: map['order_id'] as int,
      // favourite: false,
      favourite: favourite,
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
    return toMap().toString();
  }
}
