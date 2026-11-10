import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/original_zikr_source.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/repositories/custom_azkar_repo_impl.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _NoOriginals implements OriginalZikrSource {
  @override
  Future<List<DbContent>> getContentsByIds(List<int> ids) async => [];

  @override
  Future<List<DbContent>> getContentsByTitleId(int titleId) async => [];

  @override
  Future<List<DbContent>> search(String text, SearchType type, {required int limit}) async => [];
}

/// Backup/restore copies the raw `custom_azkar.db` file, so everything the feature
/// stores must survive a close -> file copy -> reopen cycle.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test("custom azkar data survives a raw file copy (backup then restore)", () async {
    final dir = await Directory.systemTemp.createTemp("custom_azkar_backup");
    addTearDown(() => dir.delete(recursive: true));

    final sourcePath = "${dir.path}${Platform.pathSeparator}source.db";
    final restoredPath = "${dir.path}${Platform.pathSeparator}${CustomAzkarDBHelper.dbName}";

    final source = CustomAzkarDBHelper(pathOverride: sourcePath);
    final sourceRepo = CustomAzkarRepoImpl(source, _NoOriginals());

    final zikrId = await sourceRepo.saveZikr(
      const CustomZikr(content: "سبحان الله", defaultCount: 33, isFavourite: true),
    );
    final titleId = await sourceRepo.createTitle(
      const CustomTitle(name: "My dhikr", isFavourite: true),
      [CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, count: 33)],
    );
    await sourceRepo.saveAlarm(CustomAlarm(titleId: titleId, hour: 5, minute: 15, isActive: true));

    // "Backup": close the connection and copy the file. "Restore": write it elsewhere.
    await source.close();
    await File(sourcePath).copy(restoredPath);

    final restored = CustomAzkarDBHelper(pathOverride: restoredPath);
    addTearDown(restored.close);
    final restoredRepo = CustomAzkarRepoImpl(restored, _NoOriginals());

    final titles = await restoredRepo.getTitles();
    expect(titles.single.name, "My dhikr");
    expect(titles.single.isFavourite, isTrue);
    expect(titles.single.itemCount, 1);

    final items = await restoredRepo.getResolvedItems(titleId);
    expect(items.single.content, "سبحان الله");
    expect(items.single.item.count, 33);

    expect((await restoredRepo.getFavouriteZikrs()).single.id, zikrId);

    final alarm = await restoredRepo.getAlarm(titleId);
    expect((alarm?.hour, alarm?.minute, alarm?.isActive), (5, 15, true));
  });
}
