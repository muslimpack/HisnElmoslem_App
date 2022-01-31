class DbChapter {
  final int id;
  final String name;
  final int orderId;

  DbChapter({required this.id, required this.name, required this.orderId});

  @override
  String toString() {
    return '''
      "id": $id,
      "name": $name,
      "orderId": $orderId
    ''';
  }
}
