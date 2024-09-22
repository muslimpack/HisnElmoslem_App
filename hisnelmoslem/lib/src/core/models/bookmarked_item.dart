import 'package:equatable/equatable.dart';

class BookmarkedItem extends Equatable {
  final int id;
  final int itemId;
  final bool bookmarked;

  const BookmarkedItem({
    required this.id,
    required this.itemId,
    required this.bookmarked,
  });

  @override
  List<Object> get props => [id, itemId, bookmarked];
}
