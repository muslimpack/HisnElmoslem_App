class DbChapter {
  int id;
  String name;
  int orderId;

  DbChapter({
    this.id = 0,
    this.name = "",
    this.orderId = 0,
  });

  DbChapter fromMap(Map<String, dynamic> map) {
    return DbChapter(
      id: map['_id'],
      name: map['name'],
      orderId: map['order_id'],
    );
  }

  @override
  String toString() {
    return '''
      "id": $id,
      "name": $name,
      "orderId": $orderId
    ''';
  }
}
