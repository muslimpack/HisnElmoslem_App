import 'package:equatable/equatable.dart';

class DbContent extends Equatable {
  final int id;
  final String content;
  final int titleId;
  final int order;
  final int count;
  final bool favourite;
  final String fadl;
  final String source;
  final String search;
  final String hokm;

  const DbContent({
    required this.id,
    required this.content,
    required this.titleId,
    required this.order,
    required this.count,
    required this.favourite,
    required this.fadl,
    required this.source,
    required this.search,
    required this.hokm,
  });

  DbContent copyWith({
    int? id,
    String? content,
    int? titleId,
    int? order,
    int? count,
    bool? favourite,
    String? fadl,
    String? source,
    String? search,
    String? hokm,
  }) {
    return DbContent(
      id: id ?? this.id,
      content: content ?? this.content,
      titleId: titleId ?? this.titleId,
      order: order ?? this.order,
      count: count ?? this.count,
      favourite: favourite ?? this.favourite,
      fadl: fadl ?? this.fadl,
      source: source ?? this.source,
      search: search ?? this.search,
      hokm: hokm ?? this.hokm,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      content,
      titleId,
      order,
      count,
      favourite,
      fadl,
      source,
      search,
      hokm,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'titleId': titleId,
      'order': order,
      'count': count,
      'favourite': favourite,
      'fadl': fadl,
      'source': source,
      'search': search,
      'hokm': hokm,
    };
  }

  factory DbContent.fromMap(Map<String, dynamic> map) {
    return DbContent(
      id: map['id'] as int,
      content: map['content'] as String,
      titleId: map['titleId'] as int,
      order: map['order'] as int,
      count: map['count'] as int,
      favourite: false,
      search: (map['search'] as String?) ?? "",
      source: (map['source'] as String?) ?? "",
      fadl: (map['fadl'] as String?) ?? "",
      hokm: (map['hokm'] as String?) ?? "",
    );
  }
}
