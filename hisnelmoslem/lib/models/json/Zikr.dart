import 'dart:convert';

List<Zikr> zikrFromJson(String str) =>
    List<Zikr>.from(json.decode(str).map((x) => Zikr.fromJson(x)));

String zikrToJson(List<Zikr> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Zikr {
  Zikr({
   required this.title,
   required this.count,
   required this.bookmark,
   required this.content,
  });

  String title;
  String count;
  String bookmark;
  List<Content> content;

  factory Zikr.fromJson(Map<String, dynamic> json) => Zikr(
    title: json["title"],
    count: json["count"],
    bookmark: json["bookmark"],
    content:
    List<Content>.from(json["content"].map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "count": count,
    "bookmark": bookmark,
    "content": List<dynamic>.from(content.map((x) => x.toJson())),
  };
}

class Content {
  Content({
  required  this.text,
  required  this.count,
  required  this.fadl,
  required  this.source,
  });

  String text;
  String count;
  String fadl;
  String source;

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    text: json["text"],
    count: json["count"],
    fadl: json["fadl"],
    source: json["source"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "count": count,
    "fadl": fadl,
    "source": source,
  };
}
