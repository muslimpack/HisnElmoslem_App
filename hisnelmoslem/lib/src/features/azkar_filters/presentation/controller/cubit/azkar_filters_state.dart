// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'azkar_filters_cubit.dart';

class AzkarFiltersState extends Equatable {
  final List<Filter> filters;
  final bool enableFilters;
  final bool enableHokmFilters;

  const AzkarFiltersState({
    required this.filters,
    required this.enableFilters,
    required this.enableHokmFilters,
  });

  @override
  List<Object> get props => [filters, enableFilters, enableHokmFilters];

  AzkarFiltersState copyWith({
    List<Filter>? filters,
    bool? enableFilters,
    bool? enableHokmFilters,
  }) {
    return AzkarFiltersState(
      filters: filters ?? this.filters,
      enableFilters: enableFilters ?? this.enableFilters,
      enableHokmFilters: enableHokmFilters ?? this.enableHokmFilters,
    );
  }
}
