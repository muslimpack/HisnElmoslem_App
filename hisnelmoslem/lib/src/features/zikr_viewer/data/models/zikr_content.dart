// ignore_for_file: public_member_api_docs, sort_constructors_first
class DbContent {
  int id;
  String content;
  int titleId;
  int orderId;
  int count;
  bool favourite;
  String fadl;
  String source;

  DbContent({
    this.id = 0,
    this.content = "",
    this.titleId = 0,
    this.count = 0,
    this.fadl = "",
    this.source = "",
    this.orderId = 0,
    this.favourite = false,
  });

  factory DbContent.fromMap(Map<String, dynamic> map) {
    bool favourite;
    if ((map['favourite'] ?? 0) == 0) {
      favourite = false;
    } else {
      favourite = true;
    }
    return DbContent(
      id: map['id'] as int,
      content: (map['content'] as String).replaceAll("\\n", "\n"),
      titleId: map['titleId'] as int,
      orderId: map['orderId'] as int,
      count: map['count'] as int,
      fadl: ((map['fadl'] ?? "") as String).replaceAll("\\n", "\n"),
      source: ((map['source'] ?? "") as String).replaceAll("\\n", "\n"),
      favourite: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'titleId': titleId,
      'count': count,
      'fadl': fadl,
      'source': source,
      'orderId': orderId,
      'favourite': favourite ? 1 : 0,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  DbContent copyWith({
    int? id,
    String? content,
    int? titleId,
    int? orderId,
    int? count,
    bool? favourite,
    String? fadl,
    String? source,
  }) {
    return DbContent(
      id: id ?? this.id,
      content: content ?? this.content,
      titleId: titleId ?? this.titleId,
      orderId: orderId ?? this.orderId,
      count: count ?? this.count,
      favourite: favourite ?? this.favourite,
      fadl: fadl ?? this.fadl,
      source: source ?? this.source,
    );
  }
}
