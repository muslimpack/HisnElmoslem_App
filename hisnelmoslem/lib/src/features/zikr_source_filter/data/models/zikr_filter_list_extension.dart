import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/repository/zikr_filter_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

extension FilterListExt on List<Filter> {
  List<DbContent> getFilteredZikr(List<DbContent> azkar) {
    final filterBySource = sl<ZikrFilterRepo>().getEnableFiltersStatus;
    final filterByHokm = sl<ZikrFilterRepo>().getEnableHokmFiltersStatus;

    if (!filterBySource && !filterByHokm) {
      return azkar;
    }

    return azkar.where((zikr) {
      if (filterBySource && !validateSource(zikr.source)) {
        return false;
      }
      if (filterByHokm && !validateHokm(zikr.hokm)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool validateSource(String source) {
    bool isValid = false;

    for (final e in this) {
      if (!e.isActivated || e.filter.isForHokm) continue;

      isValid = source.contains(e.filter.nameInDatabase);

      if (isValid) break;
    }

    return isValid;
  }

  bool validateHokm(String hokm) {
    bool isValid = false;

    for (final e in this) {
      if (!e.isActivated || !e.filter.isForHokm) continue;

      isValid = hokm == e.filter.nameInDatabase;

      if (isValid) break;
    }

    return isValid;
  }
}
