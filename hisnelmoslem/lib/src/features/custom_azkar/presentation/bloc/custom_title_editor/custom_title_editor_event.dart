part of 'custom_title_editor_bloc.dart';

sealed class CustomTitleEditorEvent extends Equatable {
  const CustomTitleEditorEvent();

  @override
  List<Object?> get props => [];
}

/// Pass [titleId] to edit, [fromOriginalTitleId] to start from a Hisn title,
/// or nothing to start from scratch.
final class CustomTitleEditorStartEvent extends CustomTitleEditorEvent {
  final int? titleId;
  final int? fromOriginalTitleId;
  final String? suggestedName;

  const CustomTitleEditorStartEvent({this.titleId, this.fromOriginalTitleId, this.suggestedName});

  @override
  List<Object?> get props => [titleId, fromOriginalTitleId, suggestedName];
}

final class CustomTitleEditorNameChangedEvent extends CustomTitleEditorEvent {
  final String name;
  const CustomTitleEditorNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

final class CustomTitleEditorDescriptionChangedEvent extends CustomTitleEditorEvent {
  final String description;
  const CustomTitleEditorDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

final class CustomTitleEditorItemsReorderedEvent extends CustomTitleEditorEvent {
  final int oldIndex;
  final int newIndex;
  const CustomTitleEditorItemsReorderedEvent({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class CustomTitleEditorItemCountChangedEvent extends CustomTitleEditorEvent {
  final int uid;
  final int count;
  const CustomTitleEditorItemCountChangedEvent({required this.uid, required this.count});

  @override
  List<Object?> get props => [uid, count];
}

final class CustomTitleEditorItemRemovedEvent extends CustomTitleEditorEvent {
  final int uid;
  const CustomTitleEditorItemRemovedEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class CustomTitleEditorCustomZikrsAddedEvent extends CustomTitleEditorEvent {
  final List<CustomZikr> zikrs;
  const CustomTitleEditorCustomZikrsAddedEvent(this.zikrs);

  @override
  List<Object?> get props => [zikrs];
}

final class CustomTitleEditorOriginalZikrsAddedEvent extends CustomTitleEditorEvent {
  final List<int> contentIds;
  const CustomTitleEditorOriginalZikrsAddedEvent(this.contentIds);

  @override
  List<Object?> get props => [contentIds];
}

final class CustomTitleEditorCustomZikrChangedEvent extends CustomTitleEditorEvent {
  final CustomZikr zikr;
  const CustomTitleEditorCustomZikrChangedEvent(this.zikr);

  @override
  List<Object?> get props => [zikr];
}

final class CustomTitleEditorCustomZikrDeletedEvent extends CustomTitleEditorEvent {
  final int zikrId;
  const CustomTitleEditorCustomZikrDeletedEvent(this.zikrId);

  @override
  List<Object?> get props => [zikrId];
}

final class CustomTitleEditorSaveEvent extends CustomTitleEditorEvent {
  const CustomTitleEditorSaveEvent();
}
