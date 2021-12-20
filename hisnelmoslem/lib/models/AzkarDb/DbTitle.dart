class DbTitle {
  int id;
  String name;
  int chapterId;
  int orderId;
  int favourite;
  int alarm;

  DbTitle({
   required this.id,
   required this.name,
   required this.chapterId,
   required this.orderId,
   required this.favourite,
   required this.alarm,
  });

  //
  // DbTitle.fromMap(Map<String, dynamic> map) {
  //   id: map['_id'];
  //   name: map['name'];
  //   chapter_id: map['chapter_id'];
  //   order_id: map['order_id'];
  //   favourite: map['favourite'];
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'chapter_id': chapterId,
      'order_id': orderId,
      'favourite': favourite,
      'alarm': alarm,
    };
  }
}
