// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbContent extends Equatable {
  final int id;
  final String content;
  final int titleId;
  final int orderId;
  final int count;
  final bool favourite;
  final String fadl;
  final String source;

  const DbContent({
    required this.id,
    required this.content,
    required this.titleId,
    required this.count,
    required this.fadl,
    required this.source,
    required this.orderId,
    required this.favourite,
  });

  factory DbContent.fromMap(Map<String, dynamic> map) {
    return DbContent(
      id: map['id'] as int,
      content: (map['content'] as String).replaceAll("\\n", "\n"),
      titleId: map['titleId'] as int,
      orderId: map['orderId'] as int,
      count: map['count'] as int,
      fadl: ((map['fadl'] ?? "") as String).replaceAll("\\n", "\n"),
      source: ((map['source'] ?? "") as String).replaceAll("\\n", "\n"),
      favourite: false,
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

  @override
  List<Object> get props {
    return [
      id,
      content,
      titleId,
      orderId,
      count,
      favourite,
      fadl,
      source,
    ];
  }
}
