// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/zikr_filter_repo.dart';

part 'azkar_filters_state.dart';

class AzkarFiltersCubit extends Cubit<AzkarFiltersState> {
  final ZikrFilterRepo zikrFilterStorage;
  AzkarFiltersCubit(
    this.zikrFilterStorage,
  ) : super(
          AzkarFiltersState(
            filters: zikrFilterStorage.getAllFilters,
            enableFilters: zikrFilterStorage.getEnableFiltersStatus,
            enableHokmFilters: zikrFilterStorage.getEnableHokmFiltersStatus,
          ),
        );

  Future toggleEnableFilters(bool enableFilters) async {
    zikrFilterStorage.setEnableFiltersStatus(enableFilters);

    emit(state.copyWith(enableFilters: enableFilters));
  }

  Future toggleEnableHokmFilters(bool enableFilters) async {
    zikrFilterStorage.setEnableHokmFiltersStatus(enableFilters);

    emit(state.copyWith(enableHokmFilters: enableFilters));
  }

  Future toggleFilter(Filter filter) async {
    final newFilter = filter.copyWith(isActivated: !filter.isActivated);
    await zikrFilterStorage.setFilterStatus(newFilter);

    final newList = List.of(state.filters).map((e) {
      if (e.filter == newFilter.filter) return newFilter;
      return e;
    }).toList();

    emit(state.copyWith(filters: newList));
  }
}
