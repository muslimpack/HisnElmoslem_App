class DbTitle {
  int id;
  String name;
  int orderId;
  bool favourite;

  DbTitle({
    this.id = 0,
    this.name = "",
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
      id: map['id'] as int,
      name: map['name'] as String,
      orderId: map['orderId'] as int,
      // favourite: false,
      favourite: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'orderId': orderId,
      'favourite': favourite ? 1 : 0,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
