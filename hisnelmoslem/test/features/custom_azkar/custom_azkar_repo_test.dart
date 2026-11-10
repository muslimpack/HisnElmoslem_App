import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/original_zikr_source.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/repositories/custom_azkar_repo_impl.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/usecases/custom_azkar_usecases.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeOriginalSource implements OriginalZikrSource {
  final Map<int, DbContent> contents;
  FakeOriginalSource(this.contents);

  @override
  Future<List<DbContent>> getContentsByIds(List<int> ids) async =>
      ids.where(contents.containsKey).map((e) => contents[e]!).toList();

  @override
  Future<List<DbContent>> getContentsByTitleId(int titleId) async =>
      contents.values.where((e) => e.titleId == titleId).toList();
}

DbContent original(int id, int titleId, String text, {int count = 3}) => DbContent(
  id: id,
  content: text,
  titleId: titleId,
  order: id,
  count: count,
  fadl: "fadl $id",
  source: "src $id",
  search: text,
  hokm: "hokm",
  audio: "",
  hasAudio: false,
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late CustomAzkarDBHelper helper;
  late FakeOriginalSource source;
  late CustomAzkarRepoImpl repo;

  setUp(() {
    helper = CustomAzkarDBHelper(pathOverride: inMemoryDatabasePath);
    source = FakeOriginalSource({
      1: original(1, 10, "alpha one"),
      2: original(2, 10, "beta two"),
      3: original(3, 11, "gamma"),
    });
    repo = CustomAzkarRepoImpl(helper, source);
  });

  tearDown(() => helper.close());

  test("create title from original title keeps order, counts and snapshots", () async {
    final items = await repo.itemsFromOriginalTitle(10);
    expect(items.map((e) => e.refId), [1, 2]);
    expect(items.first.snapshot?.content, "alpha one");

    final id = await repo.createTitle(const CustomTitle(name: "Mine", sourceTitleId: 10), items);
    final resolved = await repo.getResolvedItems(id);

    expect(resolved.map((e) => e.content), ["alpha one", "beta two"]);
    expect(resolved.first.item.count, 3);
    expect((await repo.getTitle(id))!.itemCount, 2);
  });

  test("same original zikr can be linked twice", () async {
    final item = (await repo.itemFromOriginalZikr(1))!;
    final id = await repo.createTitle(const CustomTitle(name: "Dup"), [item, item]);
    expect((await repo.getResolvedItems(id)).length, 2);
  });

  test("falls back to snapshot when original disappears", () async {
    final item = (await repo.itemFromOriginalZikr(3))!;
    final id = await repo.createTitle(const CustomTitle(name: "Snap"), [item]);

    source.contents.remove(3);
    final resolved = await repo.getResolvedItems(id);

    expect(resolved.single.isFromSnapshot, isTrue);
    expect(resolved.single.content, "gamma");
  });

  test("update replaces items, applies new order and count", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine", defaultCount: 5));
    final a = (await repo.itemFromOriginalZikr(1))!;
    final b = CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, count: 5);
    final id = await repo.createTitle(const CustomTitle(name: "T"), [a, b]);

    await repo.updateTitle(const CustomTitle(name: "T2").copyWith(id: id), [
      b.copyWith(count: 9),
      a,
    ]);

    final resolved = await repo.getResolvedItems(id);
    expect(resolved.map((e) => e.content), ["mine", "alpha one"]);
    expect(resolved.first.item.count, 9);
    expect((await repo.getTitle(id))!.name, "T2");
  });

  test("deleting a title cascades items and alarm", () async {
    final item = (await repo.itemFromOriginalZikr(1))!;
    final id = await repo.createTitle(const CustomTitle(name: "T"), [item]);
    await repo.saveAlarm(CustomAlarm(titleId: id, isActive: true));

    await repo.deleteTitle(id);

    expect(await repo.getResolvedItems(id), isEmpty);
    expect(await repo.getAlarm(id), isNull);
  });

  test("deleting a custom zikr removes its links", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine"));
    final id = await repo.createTitle(const CustomTitle(name: "T"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId),
      (await repo.itemFromOriginalZikr(1))!,
    ]);

    expect(await repo.getTitleNamesUsingZikr(zikrId), ["T"]);
    await repo.deleteZikr(zikrId);

    expect((await repo.getResolvedItems(id)).length, 1);
    expect(await repo.getZikr(zikrId), isNull);
  });

  test("alarm is upserted once per title", () async {
    final id = await repo.createTitle(const CustomTitle(name: "T"), [
      (await repo.itemFromOriginalZikr(1))!,
    ]);
    final first = await repo.saveAlarm(CustomAlarm(titleId: id, hour: 6, isActive: true));
    final second = await repo.saveAlarm(CustomAlarm(titleId: id, hour: 7));

    expect(second.id, first.id);
    expect((await repo.getAlarms()).single.hour, 7);
  });

  test("search & favourites", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "سبحان الله وبحمده"));
    final id = await repo.createTitle(const CustomTitle(name: "Morning tasbih"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId),
    ]);

    final (tCount, titles) = await repo.searchTitles(
      "tasbih",
      SearchType.typical,
      limit: 10,
      offset: 0,
    );
    expect((tCount, titles.length), (1, 1));

    final (zCount, zikrs) = await repo.searchZikrs(
      "الله بحمده",
      SearchType.allWords,
      limit: 10,
      offset: 0,
    );
    expect((zCount, zikrs.length), (1, 1));

    await repo.setTitleFavourite(id, favourite: true);
    await repo.setZikrFavourite(zikrId, favourite: true);
    expect((await repo.getFavouriteTitles()).single.id, id);
    expect((await repo.getFavouriteZikrs()).single.id, zikrId);
  });

  test("SaveCustomTitle validates name and items", () async {
    final save = SaveCustomTitle(repo);
    final item = (await repo.itemFromOriginalZikr(1))!;

    expect(
      () => save(const CustomTitle(name: "  "), [item]),
      throwsA(isA<CustomTitleValidationException>()),
    );
    expect(
      () => save(const CustomTitle(name: "ok"), []),
      throwsA(isA<CustomTitleValidationException>()),
    );
    expect(await save(const CustomTitle(name: " ok "), [item]), greaterThan(0));
    expect((await repo.getTitles()).single.name, "ok");
  });
}
