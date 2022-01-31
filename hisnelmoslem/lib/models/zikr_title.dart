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

  @override
  String toString() {
    return '''
      '_id': $id,
      'name': $name,
      'chapter_id': $chapterId,
      'order_id': $orderId,
      'favourite': $favourite,
      'alarm': $alarm,
    ''';
  }
}
