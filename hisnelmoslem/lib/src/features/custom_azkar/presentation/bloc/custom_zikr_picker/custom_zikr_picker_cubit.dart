import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/original_zikr_source.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/usecases/custom_azkar_usecases.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'custom_zikr_picker_state.dart';

/// Backs the "Add zikr" sheet: the user's zikr library and Hisn al-Muslim search.
class CustomZikrPickerCubit extends Cubit<CustomZikrPickerState> {
  static const String _debounceTag = "custom_zikr_picker_search";

  final CustomAzkarRepo repo;
  final OriginalZikrSource originalSource;
  final SaveCustomZikr _saveZikr;
  final DeleteCustomZikr _deleteZikr;
  final GetCustomZikrs _getZikrs;

  CustomZikrPickerCubit(this.repo, this.originalSource)
    : _saveZikr = SaveCustomZikr(repo),
      _deleteZikr = DeleteCustomZikr(repo),
      _getZikrs = GetCustomZikrs(repo),
      super(const CustomZikrPickerState());

  Future<void> load() async {
    emit(state.copyWith(customZikrs: await _getZikrs(), isLoading: false));
  }

  void toggleCustom(int zikrId) {
    final selected = Set<int>.from(state.selectedCustomIds);
    if (!selected.add(zikrId)) selected.remove(zikrId);
    emit(state.copyWith(selectedCustomIds: selected));
  }

  void toggleOriginal(int contentId) {
    final selected = Set<int>.from(state.selectedOriginalIds);
    if (!selected.add(contentId)) selected.remove(contentId);
    emit(state.copyWith(selectedOriginalIds: selected));
  }

  /// Saves (insert or update) a zikr and refreshes the library.
  Future<CustomZikr> saveZikr(CustomZikr zikr) async {
    final saved = await _saveZikr(zikr);
    await load();
    return saved;
  }

  Future<List<String>> titlesUsing(int zikrId) => repo.getTitleNamesUsingZikr(zikrId);

  Future<void> deleteZikr(int zikrId) async {
    await _deleteZikr(zikrId);
    emit(
      state.copyWith(
        selectedCustomIds: Set<int>.from(state.selectedCustomIds)..remove(zikrId),
      ),
    );
    await load();
  }

  void search(String text) {
    EasyDebounce.debounce(_debounceTag, const Duration(milliseconds: 400), () async {
      if (isClosed) return;
      final query = text.trim();
      if (query.isEmpty) {
        emit(state.copyWith(query: "", originalResults: const []));
        return;
      }
      final results = await originalSource.search(query, SearchType.typical, limit: 50);
      if (isClosed) return;
      emit(state.copyWith(query: query, originalResults: results));
    });
  }

  @override
  Future<void> close() {
    EasyDebounce.cancel(_debounceTag);
    return super.close();
  }
}
