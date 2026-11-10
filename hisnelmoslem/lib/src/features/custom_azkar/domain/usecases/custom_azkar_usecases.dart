import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';

class GetCustomTitles {
  final CustomAzkarRepo repo;
  const GetCustomTitles(this.repo);
  Future<List<CustomTitle>> call() => repo.getTitles();
}

class DeleteCustomTitle {
  final CustomAzkarRepo repo;
  const DeleteCustomTitle(this.repo);
  Future<void> call(int id) => repo.deleteTitle(id);
}

/// Validation failures raised by [SaveCustomTitle].
enum CustomTitleError { emptyName, noItems }

class CustomTitleValidationException implements Exception {
  final CustomTitleError error;
  const CustomTitleValidationException(this.error);
}

/// Creates (id == 0) or updates a title together with its items.
class SaveCustomTitle {
  final CustomAzkarRepo repo;
  const SaveCustomTitle(this.repo);

  Future<int> call(CustomTitle title, List<CustomTitleItem> items) async {
    if (title.name.trim().isEmpty) {
      throw const CustomTitleValidationException(CustomTitleError.emptyName);
    }
    if (items.isEmpty) {
      throw const CustomTitleValidationException(CustomTitleError.noItems);
    }
    final trimmed = title.copyWith(
      name: title.name.trim(),
      description: title.description.trim(),
    );
    if (title.id == 0) return repo.createTitle(trimmed, items);
    await repo.updateTitle(trimmed, items);
    return title.id;
  }
}

class GetResolvedTitleItems {
  final CustomAzkarRepo repo;
  const GetResolvedTitleItems(this.repo);
  Future<List<ResolvedTitleItem>> call(int titleId) => repo.getResolvedItems(titleId);
}

class GetItemsFromOriginalTitle {
  final CustomAzkarRepo repo;
  const GetItemsFromOriginalTitle(this.repo);
  Future<List<CustomTitleItem>> call(int originalTitleId) =>
      repo.itemsFromOriginalTitle(originalTitleId);
}

class GetItemFromOriginalZikr {
  final CustomAzkarRepo repo;
  const GetItemFromOriginalZikr(this.repo);
  Future<CustomTitleItem?> call(int originalContentId) =>
      repo.itemFromOriginalZikr(originalContentId);
}

class GetCustomZikrs {
  final CustomAzkarRepo repo;
  const GetCustomZikrs(this.repo);
  Future<List<CustomZikr>> call() => repo.getZikrs();
}

class SaveCustomZikr {
  final CustomAzkarRepo repo;
  const SaveCustomZikr(this.repo);

  Future<CustomZikr> call(CustomZikr zikr) async {
    final trimmed = zikr.copyWith(
      content: zikr.content.trim(),
      source: zikr.source.trim(),
      fadl: zikr.fadl.trim(),
      defaultCount: zikr.defaultCount < 1 ? 1 : zikr.defaultCount,
    );
    final id = await repo.saveZikr(trimmed);
    return trimmed.copyWith(id: id);
  }
}

class DeleteCustomZikr {
  final CustomAzkarRepo repo;
  const DeleteCustomZikr(this.repo);
  Future<void> call(int id) => repo.deleteZikr(id);
}

class ToggleCustomFavourite {
  final CustomAzkarRepo repo;
  const ToggleCustomFavourite(this.repo);
  Future<void> title(int id, {required bool favourite}) =>
      repo.setTitleFavourite(id, favourite: favourite);
  Future<void> zikr(int id, {required bool favourite}) =>
      repo.setZikrFavourite(id, favourite: favourite);
}
