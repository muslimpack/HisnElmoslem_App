class DbContent {
  int id;
  String content;
  int chapterId;
  int titleId;
  int orderId;
  int count;
  bool favourite;
  String fadl;
  String source;

  DbContent({
    this.id = 0,
    this.content = "",
    this.chapterId = 0,
    this.titleId = 0,
    this.count = 0,
    this.fadl = "",
    this.source = "",
    this.orderId = 0,
    this.favourite = false,
  });

  factory DbContent.fromMap(Map<String, dynamic> map) {
    return DbContent(
      id: map['_id'],
      content: (map['content'] as String).replaceAll("\\n", "\n"),
      chapterId: map['chapter_id'],
      titleId: map['title_id'],
      orderId: map['order_id'],
      count: map['count'],
      fadl: ((map['fadl'] ?? "") as String).replaceAll("\\n", "\n"),
      source: ((map['source'] ?? "") as String).replaceAll("\\n", "\n"),
      favourite: (map['favourite'] ?? 0) == 0 ? false : true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'content': content,
      'chapter_id': chapterId,
      'title_id': titleId,
      'count': count,
      'fadl': fadl,
      'source': source,
      'order_id': orderId,
      'favourite': favourite ? 1 : 0,
    };
  }

  @override
  String toString() {
    return "'_id': $id |'content': $content | 'chapter_id': $chapterId |'title_id': $titleId |'count': $count |'fadl': $fadl,|'source': $source,|'order_id': $orderId,|'favourite': $favourite";
  }
}
