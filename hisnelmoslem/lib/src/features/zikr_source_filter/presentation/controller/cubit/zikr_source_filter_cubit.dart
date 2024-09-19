// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/repository/zikr_filter_repo.dart';

part 'zikr_source_filter_state.dart';

class ZikrSourceFilterCubit extends Cubit<ZikrSourceFilterState> {
  final ZikrFilterRepo zikrFilterStorage;
  ZikrSourceFilterCubit(
    this.zikrFilterStorage,
  ) : super(
          const ZikrSourceFilterState(
            filters: [],
            enableFilters: false,
            enableHokmFilters: false,
          ),
        );

  void start() {
    final List<Filter> filters = zikrFilterStorage.getAllFilters();

    emit(
      ZikrSourceFilterState(
        filters: filters,
        enableFilters: zikrFilterStorage.getEnableFiltersStatus(),
        enableHokmFilters: zikrFilterStorage.getEnableHokmFiltersStatus(),
      ),
    );
  }

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
