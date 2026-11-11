part of 'custom_zikr_picker_cubit.dart';

class CustomZikrPickerState extends Equatable {
  final bool isLoading;
  final List<CustomZikr> customZikrs;
  final Set<int> selectedCustomIds;
  final String query;
  final List<DbContent> originalResults;
  final Set<int> selectedOriginalIds;

  const CustomZikrPickerState({
    this.isLoading = true,
    this.customZikrs = const [],
    this.selectedCustomIds = const {},
    this.query = "",
    this.originalResults = const [],
    this.selectedOriginalIds = const {},
  });

  int get selectedCount => selectedCustomIds.length + selectedOriginalIds.length;

  CustomZikrPickerState copyWith({
    bool? isLoading,
    List<CustomZikr>? customZikrs,
    Set<int>? selectedCustomIds,
    String? query,
    List<DbContent>? originalResults,
    Set<int>? selectedOriginalIds,
  }) {
    return CustomZikrPickerState(
      isLoading: isLoading ?? this.isLoading,
      customZikrs: customZikrs ?? this.customZikrs,
      selectedCustomIds: selectedCustomIds ?? this.selectedCustomIds,
      query: query ?? this.query,
      originalResults: originalResults ?? this.originalResults,
      selectedOriginalIds: selectedOriginalIds ?? this.selectedOriginalIds,
    );
  }

  @override
  List<Object> get props => [
    isLoading,
    customZikrs,
    selectedCustomIds,
    query,
    originalResults,
    selectedOriginalIds,
  ];
}
