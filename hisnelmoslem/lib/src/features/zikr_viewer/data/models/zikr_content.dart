// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';

class DbContent extends Equatable {
  final int id;
  final String content;
  final int titleId;
  final int order;
  final int count;
  final String fadl;
  final String source;
  final String search;
  final String hokm;
  final String audio;
  final bool hasAudio;

  const DbContent({
    required this.id,
    required this.content,
    required this.titleId,
    required this.order,
    required this.count,
    required this.fadl,
    required this.source,
    required this.search,
    required this.hokm,
    required this.audio,
    required this.hasAudio,
  });

  DbContent copyWith({
    int? id,
    String? content,
    int? titleId,
    int? order,
    int? count,
    String? fadl,
    String? source,
    String? search,
    String? hokm,
    String? audio,
  }) {
    return DbContent(
      id: id ?? this.id,
      content: content ?? this.content,
      titleId: titleId ?? this.titleId,
      order: order ?? this.order,
      count: count ?? this.count,
      fadl: fadl ?? this.fadl,
      source: source ?? this.source,
      search: search ?? this.search,
      hokm: hokm ?? this.hokm,
      audio: audio ?? this.audio,
      hasAudio: hasAudio,
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
      fadl,
      source,
      search,
      hokm,
      audio,
    ];
  }

  factory DbContent.fromMap(Map<String, dynamic> map) {
    final String? audio = map['audio'] as String?;
    return DbContent(
      id: map['id'] as int,
      content: map['content'] as String,
      titleId: map['titleId'] as int,
      order: map['order'] as int,
      count: map['count'] as int,
      search: (map['search'] as String?) ?? "",
      source: (map['source'] as String?) ?? "",
      fadl: (map['fadl'] as String?) ?? "",
      hokm: (map['hokm'] as String?) ?? "",
      audio: audio ?? "",
      hasAudio: audio != null,
    );
  }
}

extension DbContentExtension on DbContent {
  Future<String> sharedText() async {
    final StringBuffer sb = StringBuffer();
    final content = await getPlainText();
    sb.writeln("$content\n");
    sb.writeln("🔢عدد المرات: $count\n");
    if (fadl.isNotEmpty) sb.writeln("🏆الفضل: $fadl\n");
    if (source.isNotEmpty) sb.writeln("📚المصدر:\n$source");
    return sb.toString();
  }
}
