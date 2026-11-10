import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Read-only access to the bundled Hisn al-Muslim zikrs.
/// The custom azkar feature depends on this abstraction, never on writes.
abstract interface class OriginalZikrSource {
  Future<List<DbContent>> getContentsByIds(List<int> ids);
  Future<List<DbContent>> getContentsByTitleId(int titleId);
}

class HisnOriginalZikrSource implements OriginalZikrSource {
  final HisnDBHelper hisnDBHelper;
  const HisnOriginalZikrSource(this.hisnDBHelper);

  @override
  Future<List<DbContent>> getContentsByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return hisnDBHelper.getContentsByIds(ids: ids);
  }

  @override
  Future<List<DbContent>> getContentsByTitleId(int titleId) {
    return hisnDBHelper.getContentsByTitleId(titleId: titleId);
  }
}
