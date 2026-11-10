import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';

/// Contract for everything custom-azkar related.
/// Implementations must never write to the bundled Hisn al-Muslim database.
abstract interface class CustomAzkarRepo {
  ///MARK: Titles
  Future<List<CustomTitle>> getTitles();
  Future<CustomTitle?> getTitle(int id);

  /// Creates the title and its [items] atomically. Returns the new id.
  Future<int> createTitle(CustomTitle title, List<CustomTitleItem> items);

  /// Updates the title and replaces all its items atomically (order = list order).
  Future<void> updateTitle(CustomTitle title, List<CustomTitleItem> items);
  Future<void> deleteTitle(int id);
  Future<void> setTitleFavourite(int id, {required bool favourite});

  ///MARK: Items
  /// Items of a title with their display text resolved (live original, else snapshot).
  Future<List<ResolvedTitleItem>> getResolvedItems(int titleId);

  /// Builds items (with snapshots) from every zikr of an original title.
  Future<List<CustomTitleItem>> itemsFromOriginalTitle(int originalTitleId);

  /// Builds an item (with snapshot) pointing to an original zikr.
  Future<CustomTitleItem?> itemFromOriginalZikr(int originalContentId);

  ///MARK: Custom zikrs
  Future<List<CustomZikr>> getZikrs();
  Future<CustomZikr?> getZikr(int id);
  Future<int> saveZikr(CustomZikr zikr);

  /// Names of custom titles that use the zikr.
  Future<List<String>> getTitleNamesUsingZikr(int zikrId);

  /// Deletes the zikr and every link to it.
  Future<void> deleteZikr(int id);
  Future<void> setZikrFavourite(int id, {required bool favourite});

  ///MARK: Search & favourites
  Future<(int, List<CustomTitle>)> searchTitles(
    String text,
    SearchType type, {
    required int limit,
    required int offset,
  });
  Future<(int, List<CustomZikr>)> searchZikrs(
    String text,
    SearchType type, {
    required int limit,
    required int offset,
  });
  Future<List<CustomTitle>> getFavouriteTitles();
  Future<List<CustomZikr>> getFavouriteZikrs();

  ///MARK: Alarms
  Future<List<CustomAlarm>> getAlarms();
  Future<CustomAlarm?> getAlarm(int titleId);

  /// Inserts or replaces the title's alarm. Returns the stored alarm.
  Future<CustomAlarm> saveAlarm(CustomAlarm alarm);
  Future<void> deleteAlarm(int titleId);
}
