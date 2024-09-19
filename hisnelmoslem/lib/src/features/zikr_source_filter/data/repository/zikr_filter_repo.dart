import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter_enum.dart';

class ZikrFilterRepo {
  final GetStorage box;

  ZikrFilterRepo(this.box);

  List<Filter> get getAllFilters {
    return ZikrFilter.values
        .map((e) => Filter(filter: e, isActivated: getFilterStatus(e)))
        .toList();
  }

  static const String _filterPrefixNameKey = "ZikrFilterStorage";

  static const String _enableFiltersKey =
      "${_filterPrefixNameKey}enableFilters";

  /// Filters for zikr source
  bool get getEnableFiltersStatus {
    final bool? data = box.read(_enableFiltersKey);
    return data ?? false;
  }

  /// Filters for zikr source
  Future setEnableFiltersStatus(bool activateFilters) async {
    return box.write(_enableFiltersKey, activateFilters);
  }

  static const String _enableHokmFiltersKey =
      "${_filterPrefixNameKey}enableHokmFilters";

  /// Filters for zikr Hokm
  bool get getEnableHokmFiltersStatus {
    final bool? data = box.read(_enableHokmFiltersKey);
    return data ?? false;
  }

  /// Filters for zikr Hokm
  Future setEnableHokmFiltersStatus(bool activateFilters) async {
    return box.write(_enableHokmFiltersKey, activateFilters);
  }

  bool getFilterStatus(ZikrFilter zikrFilter) {
    final bool? data = box.read(_getZikrFilterKey(zikrFilter));
    return data ?? true;
  }

  Future setFilterStatus(Filter filter) async {
    return box.write(_getZikrFilterKey(filter.filter), filter.isActivated);
  }

  String _getZikrFilterKey(ZikrFilter filter) {
    return "$_filterPrefixNameKey${filter.name}";
  }
}
