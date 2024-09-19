// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/azakr_filters_repo.dart';

part 'azkar_filters_state.dart';

class AzkarFiltersCubit extends Cubit<AzkarFiltersState> {
  final AzkarFiltersRepo azkarFiltersRepo;
  AzkarFiltersCubit(
    this.azkarFiltersRepo,
  ) : super(
          AzkarFiltersState(
            filters: azkarFiltersRepo.getAllFilters,
            enableFilters: azkarFiltersRepo.getEnableFiltersStatus,
            enableHokmFilters: azkarFiltersRepo.getEnableHokmFiltersStatus,
          ),
        );

  Future toggleEnableFilters(bool enableFilters) async {
    azkarFiltersRepo.setEnableFiltersStatus(enableFilters);

    emit(state.copyWith(enableFilters: enableFilters));
  }

  Future toggleEnableHokmFilters(bool enableFilters) async {
    azkarFiltersRepo.setEnableHokmFiltersStatus(enableFilters);

    emit(state.copyWith(enableHokmFilters: enableFilters));
  }

  Future toggleFilter(Filter filter) async {
    final newFilter = filter.copyWith(isActivated: !filter.isActivated);
    await azkarFiltersRepo.setFilterStatus(newFilter);

    final newList = List.of(state.filters).map((e) {
      if (e.filter == newFilter.filter) return newFilter;
      return e;
    }).toList();

    emit(state.copyWith(filters: newList));
  }
}
