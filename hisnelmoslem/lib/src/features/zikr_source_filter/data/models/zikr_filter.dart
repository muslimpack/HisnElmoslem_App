import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter_enum.dart';

class Filter extends Equatable {
  final ZikrFilter filter;
  final bool isActivated;

  const Filter({
    required this.filter,
    required this.isActivated,
  });

  Filter copyWith({
    ZikrFilter? filter,
    bool? isActivated,
  }) {
    return Filter(
      filter: filter ?? this.filter,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  List<Object> get props => [filter, isActivated];
}
