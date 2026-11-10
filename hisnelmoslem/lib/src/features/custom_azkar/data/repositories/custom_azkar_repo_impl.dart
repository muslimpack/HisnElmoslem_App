import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/original_zikr_source.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite/sqflite.dart';

class CustomAzkarRepoImpl implements CustomAzkarRepo {
  final CustomAzkarDBHelper dbHelper;
  final OriginalZikrSource originalSource;

  const CustomAzkarRepoImpl(this.dbHelper, this.originalSource);

  static const _titles = CustomAzkarDBHelper.titlesTable;
  static const _zikrs = CustomAzkarDBHelper.zikrsTable;
  static const _items = CustomAzkarDBHelper.itemsTable;
  static const _alarms = CustomAzkarDBHelper.alarmsTable;

  String get _now => DateTime.now().toIso8601String();

  ///MARK: Mapping
  CustomTitle _titleFromMap(Map<String, Object?> m) {
    return CustomTitle(
      id: m['id']! as int,
      name: m['name']! as String,
      description: (m['description'] as String?) ?? "",
      sourceTitleId: m['source_title_id'] as int?,
      isFavourite: (m['is_favourite'] as int? ?? 0) == 1,
      sortOrder: m['sort_order'] as int? ?? 0,
      itemCount: m['item_count'] as int? ?? 0,
    );
  }

  CustomZikr _zikrFromMap(Map<String, Object?> m) {
    return CustomZikr(
      id: m['id']! as int,
      content: m['content']! as String,
      source: (m['source'] as String?) ?? "",
      fadl: (m['fadl'] as String?) ?? "",
      defaultCount: m['default_count'] as int? ?? 1,
      isFavourite: (m['is_favourite'] as int? ?? 0) == 1,
    );
  }

  CustomTitleItem _itemFromMap(Map<String, Object?> m) {
    final kind = CustomItemKind.fromName(m['kind']! as String);
    final snapContent = m['snap_content'] as String?;
    return CustomTitleItem(
      id: m['id']! as int,
      titleId: m['title_id']! as int,
      kind: kind,
      refId: m['ref_id']! as int,
      sortOrder: m['sort_order']! as int,
      count: m['count'] as int? ?? 1,
      snapshot: snapContent == null
          ? null
          : ZikrSnapshot(
              content: snapContent,
              source: (m['snap_source'] as String?) ?? "",
              fadl: (m['snap_fadl'] as String?) ?? "",
              hokm: (m['snap_hokm'] as String?) ?? "",
            ),
    );
  }

  Map<String, Object?> _itemToMap(CustomTitleItem item, int titleId, int order) {
    return {
      'title_id': titleId,
      'kind': item.kind.name,
      'ref_id': item.refId,
      'sort_order': order,
      'count': item.count < 1 ? 1 : item.count,
      'snap_content': item.snapshot?.content,
      'snap_source': item.snapshot?.source,
      'snap_fadl': item.snapshot?.fadl,
      'snap_hokm': item.snapshot?.hokm,
    };
  }

  CustomTitleItem _originalToItem(DbContent c, {int sortOrder = 0}) {
    return CustomTitleItem(
      kind: CustomItemKind.original,
      refId: c.id,
      sortOrder: sortOrder,
      count: c.count < 1 ? 1 : c.count,
      snapshot: ZikrSnapshot(
        content: c.content,
        source: c.source,
        fadl: c.fadl,
        hokm: c.hokm,
      ),
    );
  }

  static const String _titleSelect =
      'SELECT t.*, (SELECT COUNT(*) FROM $_items i WHERE i.title_id = t.id) AS item_count '
      'FROM $_titles t';

  ///MARK: Titles
  @override
  Future<List<CustomTitle>> getTitles() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('$_titleSelect ORDER BY t.sort_order ASC, t.id ASC');
    return rows.map(_titleFromMap).toList();
  }

  @override
  Future<CustomTitle?> getTitle(int id) async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('$_titleSelect WHERE t.id = ?', [id]);
    return rows.isEmpty ? null : _titleFromMap(rows.first);
  }

  @override
  Future<int> createTitle(CustomTitle title, List<CustomTitleItem> items) async {
    final db = await dbHelper.database;
    return db.transaction((txn) async {
      final maxOrder = Sqflite.firstIntValue(
        await txn.rawQuery('SELECT MAX(sort_order) FROM $_titles'),
      );
      final id = await txn.insert(_titles, {
        'name': title.name,
        'description': title.description,
        'source_title_id': title.sourceTitleId,
        'is_favourite': title.isFavourite ? 1 : 0,
        'sort_order': (maxOrder ?? -1) + 1,
        'created': _now,
        'updated': _now,
      });
      await _insertItems(txn, id, items);
      return id;
    });
  }

  Future<void> _insertItems(DatabaseExecutor txn, int titleId, List<CustomTitleItem> items) async {
    for (var i = 0; i < items.length; i++) {
      await txn.insert(_items, _itemToMap(items[i], titleId, i));
    }
  }

  @override
  Future<void> updateTitle(CustomTitle title, List<CustomTitleItem> items) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        _titles,
        {
          'name': title.name,
          'description': title.description,
          'updated': _now,
        },
        where: 'id = ?',
        whereArgs: [title.id],
      );
      await txn.delete(_items, where: 'title_id = ?', whereArgs: [title.id]);
      await _insertItems(txn, title.id, items);
    });
  }

  @override
  Future<void> deleteTitle(int id) async {
    final db = await dbHelper.database;
    // Items and alarm rows are removed by ON DELETE CASCADE.
    await db.delete(_titles, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setTitleFavourite(int id, {required bool favourite}) async {
    final db = await dbHelper.database;
    await db.update(
      _titles,
      {'is_favourite': favourite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ///MARK: Items
  @override
  Future<List<ResolvedTitleItem>> getResolvedItems(int titleId) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      _items,
      where: 'title_id = ?',
      whereArgs: [titleId],
      orderBy: 'sort_order ASC, id ASC',
    );
    final items = rows.map(_itemFromMap).toList();

    final originalIds = items
        .where((e) => e.kind == CustomItemKind.original)
        .map((e) => e.refId)
        .toSet()
        .toList();
    final customIds = items
        .where((e) => e.kind == CustomItemKind.custom)
        .map((e) => e.refId)
        .toSet()
        .toList();

    final originals = {
      for (final c in await originalSource.getContentsByIds(originalIds)) c.id: c,
    };

    final customs = <int, CustomZikr>{};
    if (customIds.isNotEmpty) {
      final zikrRows = await db.query(
        _zikrs,
        where: 'id IN (${customIds.map((_) => '?').join(',')})',
        whereArgs: customIds,
      );
      for (final r in zikrRows) {
        final z = _zikrFromMap(r);
        customs[z.id] = z;
      }
    }

    final result = <ResolvedTitleItem>[];
    for (final item in items) {
      switch (item.kind) {
        case CustomItemKind.original:
          final live = originals[item.refId];
          if (live != null) {
            result.add(
              ResolvedTitleItem(
                item: item,
                content: live.content,
                source: live.source,
                fadl: live.fadl,
                hokm: live.hokm,
                audio: live.audio,
              ),
            );
          } else if (item.snapshot != null) {
            final s = item.snapshot!;
            result.add(
              ResolvedTitleItem(
                item: item,
                content: s.content,
                source: s.source,
                fadl: s.fadl,
                hokm: s.hokm,
                isFromSnapshot: true,
              ),
            );
          }

        case CustomItemKind.custom:
          final z = customs[item.refId];
          if (z != null) {
            result.add(
              ResolvedTitleItem(
                item: item,
                content: z.content,
                source: z.source,
                fadl: z.fadl,
              ),
            );
          }
      }
    }
    return result;
  }

  @override
  Future<List<CustomTitleItem>> itemsFromOriginalTitle(int originalTitleId) async {
    final contents = await originalSource.getContentsByTitleId(originalTitleId);
    return [
      for (var i = 0; i < contents.length; i++) _originalToItem(contents[i], sortOrder: i),
    ];
  }

  @override
  Future<CustomTitleItem?> itemFromOriginalZikr(int originalContentId) async {
    final contents = await originalSource.getContentsByIds([originalContentId]);
    if (contents.isEmpty) return null;
    return _originalToItem(contents.first);
  }

  ///MARK: Custom zikrs
  @override
  Future<List<CustomZikr>> getZikrs() async {
    final db = await dbHelper.database;
    final rows = await db.query(_zikrs, orderBy: 'id DESC');
    return rows.map(_zikrFromMap).toList();
  }

  @override
  Future<CustomZikr?> getZikr(int id) async {
    final db = await dbHelper.database;
    final rows = await db.query(_zikrs, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _zikrFromMap(rows.first);
  }

  @override
  Future<int> saveZikr(CustomZikr zikr) async {
    final db = await dbHelper.database;
    final values = {
      'content': zikr.content,
      'source': zikr.source,
      'fadl': zikr.fadl,
      'default_count': zikr.defaultCount,
      'is_favourite': zikr.isFavourite ? 1 : 0,
      'updated': _now,
    };
    if (zikr.id == 0) {
      return db.insert(_zikrs, {...values, 'created': _now});
    }
    await db.update(_zikrs, values, where: 'id = ?', whereArgs: [zikr.id]);
    return zikr.id;
  }

  @override
  Future<List<String>> getTitleNamesUsingZikr(int zikrId) async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT t.name FROM $_titles t JOIN $_items i ON i.title_id = t.id '
      "WHERE i.kind = 'custom' AND i.ref_id = ? ORDER BY t.name",
      [zikrId],
    );
    return rows.map((e) => e['name']! as String).toList();
  }

  @override
  Future<void> deleteZikr(int id) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(_items, where: "kind = 'custom' AND ref_id = ?", whereArgs: [id]);
      await txn.delete(_zikrs, where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> setZikrFavourite(int id, {required bool favourite}) async {
    final db = await dbHelper.database;
    await db.update(
      _zikrs,
      {'is_favourite': favourite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ///MARK: Search & favourites
  ({String where, List<Object?> args}) _searchWhere(
    String text,
    SearchType type,
    String column,
  ) {
    final words = text.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (words.isEmpty) return (where: '0', args: const []);

    switch (type) {
      case SearchType.typical:
        return (where: '$column LIKE ?', args: ['%${text.trim()}%']);
      case SearchType.allWords:
        return (
          where: words.map((_) => '$column LIKE ?').join(' AND '),
          args: words.map((w) => '%$w%').toList(),
        );
      case SearchType.anyWords:
        return (
          where: words.map((_) => '$column LIKE ?').join(' OR '),
          args: words.map((w) => '%$w%').toList(),
        );
    }
  }

  @override
  Future<(int, List<CustomTitle>)> searchTitles(
    String text,
    SearchType type, {
    required int limit,
    required int offset,
  }) async {
    if (text.trim().isEmpty) return (0, <CustomTitle>[]);
    final db = await dbHelper.database;
    final w = _searchWhere(text, type, 't.name');
    final rows = await db.rawQuery(
      '$_titleSelect WHERE ${w.where} ORDER BY t.id LIMIT ? OFFSET ?',
      [...w.args, limit, offset],
    );
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_titles t WHERE ${w.where}', w.args),
        ) ??
        0;
    return (count, rows.map(_titleFromMap).toList());
  }

  @override
  Future<(int, List<CustomZikr>)> searchZikrs(
    String text,
    SearchType type, {
    required int limit,
    required int offset,
  }) async {
    if (text.trim().isEmpty) return (0, <CustomZikr>[]);
    final db = await dbHelper.database;
    final w = _searchWhere(text, type, 'content');
    final rows = await db.rawQuery(
      'SELECT * FROM $_zikrs WHERE ${w.where} ORDER BY id LIMIT ? OFFSET ?',
      [...w.args, limit, offset],
    );
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_zikrs WHERE ${w.where}', w.args),
        ) ??
        0;
    return (count, rows.map(_zikrFromMap).toList());
  }

  @override
  Future<List<CustomTitle>> getFavouriteTitles() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery(
      '$_titleSelect WHERE t.is_favourite = 1 ORDER BY t.sort_order ASC, t.id ASC',
    );
    return rows.map(_titleFromMap).toList();
  }

  @override
  Future<List<CustomZikr>> getFavouriteZikrs() async {
    final db = await dbHelper.database;
    final rows = await db.query(_zikrs, where: 'is_favourite = 1', orderBy: 'id DESC');
    return rows.map(_zikrFromMap).toList();
  }

  ///MARK: Alarms
  CustomAlarm _alarmFromMap(Map<String, Object?> m) {
    final typeName = (m['repeat_type'] as String?) ?? "";
    return CustomAlarm(
      id: m['id']! as int,
      titleId: m['title_id']! as int,
      body: (m['body'] as String?) ?? "",
      repeatType:
          AlarmRepeatType.values.where((e) => e.name == typeName).firstOrNull ??
          AlarmRepeatType.daily,
      hour: m['hour']! as int,
      minute: m['minute']! as int,
      isActive: (m['is_active'] as int? ?? 0) == 1,
    );
  }

  @override
  Future<List<CustomAlarm>> getAlarms() async {
    final db = await dbHelper.database;
    return (await db.query(_alarms)).map(_alarmFromMap).toList();
  }

  @override
  Future<CustomAlarm?> getAlarm(int titleId) async {
    final db = await dbHelper.database;
    final rows = await db.query(_alarms, where: 'title_id = ?', whereArgs: [titleId]);
    return rows.isEmpty ? null : _alarmFromMap(rows.first);
  }

  @override
  Future<CustomAlarm> saveAlarm(CustomAlarm alarm) async {
    final db = await dbHelper.database;
    final values = {
      'title_id': alarm.titleId,
      'body': alarm.body,
      'repeat_type': alarm.repeatType.name,
      'hour': alarm.hour,
      'minute': alarm.minute,
      'is_active': alarm.isActive ? 1 : 0,
    };
    final existing = await getAlarm(alarm.titleId);
    if (existing == null) {
      final id = await db.insert(_alarms, values);
      return alarm.copyWith(id: id);
    }
    await db.update(_alarms, values, where: 'id = ?', whereArgs: [existing.id]);
    return alarm.copyWith(id: existing.id);
  }

  @override
  Future<void> deleteAlarm(int titleId) async {
    final db = await dbHelper.database;
    await db.delete(_alarms, where: 'title_id = ?', whereArgs: [titleId]);
  }
}
