import 'package:equatable/equatable.dart';

/// A user-created title (a collection of zikrs) that lives outside the original DB.
class CustomTitle extends Equatable {
  final int id;
  final String name;
  final String description;

  /// Original title id this title was started from (informational only).
  final int? sourceTitleId;
  final bool isFavourite;
  final int sortOrder;

  /// Number of items linked to this title (computed by the data layer).
  final int itemCount;

  const CustomTitle({
    this.id = 0,
    required this.name,
    this.description = "",
    this.sourceTitleId,
    this.isFavourite = false,
    this.sortOrder = 0,
    this.itemCount = 0,
  });

  CustomTitle copyWith({
    int? id,
    String? name,
    String? description,
    int? sourceTitleId,
    bool? isFavourite,
    int? sortOrder,
    int? itemCount,
  }) {
    return CustomTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sourceTitleId: sourceTitleId ?? this.sourceTitleId,
      isFavourite: isFavourite ?? this.isFavourite,
      sortOrder: sortOrder ?? this.sortOrder,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    sourceTitleId,
    isFavourite,
    sortOrder,
    itemCount,
  ];
}
