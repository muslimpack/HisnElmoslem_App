import 'package:equatable/equatable.dart';

/// A zikr authored by the user.
class CustomZikr extends Equatable {
  final int id;
  final String content;
  final String source;
  final String fadl;
  final int defaultCount;
  final bool isFavourite;

  const CustomZikr({
    this.id = 0,
    required this.content,
    this.source = "",
    this.fadl = "",
    this.defaultCount = 1,
    this.isFavourite = false,
  });

  CustomZikr copyWith({
    int? id,
    String? content,
    String? source,
    String? fadl,
    int? defaultCount,
    bool? isFavourite,
  }) {
    return CustomZikr(
      id: id ?? this.id,
      content: content ?? this.content,
      source: source ?? this.source,
      fadl: fadl ?? this.fadl,
      defaultCount: defaultCount ?? this.defaultCount,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object> get props => [id, content, source, fadl, defaultCount, isFavourite];
}
