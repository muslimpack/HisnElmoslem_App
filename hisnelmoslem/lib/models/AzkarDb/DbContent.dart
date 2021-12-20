class DbContent {
  int id;
  String content;
  int chapterId;
  int titleId;
  int orderId;
  int count;
  String fadl;
  String source;

  DbContent({
    required this.id,
    required this.content,
    required this.chapterId,
    required this.titleId,
    required this.count,
    required this.fadl,
    required this.source,
    required this.orderId,
  });

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
    };
  }
}
