import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/usecases/custom_azkar_usecases.dart';

part 'custom_title_editor_event.dart';
part 'custom_title_editor_state.dart';

/// Edits a draft custom title (name, description, ordered items with counts).
/// Nothing is written until [CustomTitleEditorSaveEvent].
class CustomTitleEditorBloc extends Bloc<CustomTitleEditorEvent, CustomTitleEditorState> {
  final CustomAzkarRepo repo;
  final CustomAudioStorage audioStorage;
  final SaveCustomTitle _saveTitle;
  final GetResolvedTitleItems _getResolvedItems;
  final GetItemsFromOriginalTitle _getItemsFromOriginalTitle;
  final GetItemFromOriginalZikr _getItemFromOriginalZikr;

  int _nextUid = 1;

  /// Recordings made in this editor session. They are pinned (safe from cleanup)
  /// and deleted again if the draft is abandoned.
  final Set<String> _draftFiles = {};

  /// Recordings that were written to the database by a save.
  final Set<String> _savedFiles = {};

  CustomTitleEditorBloc(this.repo, this.audioStorage)
    : _saveTitle = SaveCustomTitle(repo),
      _getResolvedItems = GetResolvedTitleItems(repo),
      _getItemsFromOriginalTitle = GetItemsFromOriginalTitle(repo),
      _getItemFromOriginalZikr = GetItemFromOriginalZikr(repo),
      super(const CustomTitleEditorLoadingState()) {
    on<CustomTitleEditorStartEvent>(_start);
    on<CustomTitleEditorNameChangedEvent>(_nameChanged);
    on<CustomTitleEditorDescriptionChangedEvent>(_descriptionChanged);
    on<CustomTitleEditorItemsReorderedEvent>(_reorder);
    on<CustomTitleEditorItemCountChangedEvent>(_countChanged);
    on<CustomTitleEditorItemAudioChangedEvent>(_audioChanged);
    on<CustomTitleEditorItemRemovedEvent>(_remove);
    on<CustomTitleEditorCustomZikrsAddedEvent>(_addCustomZikrs);
    on<CustomTitleEditorOriginalZikrsAddedEvent>(_addOriginalZikrs);
    on<CustomTitleEditorCustomZikrChangedEvent>(_customZikrChanged);
    on<CustomTitleEditorCustomZikrDeletedEvent>(_customZikrDeleted);
    on<CustomTitleEditorSaveEvent>(_save);
  }

  EditorEntry _entry(ResolvedTitleItem resolved) {
    return EditorEntry(uid: _nextUid++, resolved: resolved);
  }

  Future<void> _start(
    CustomTitleEditorStartEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    _nextUid = 1;

    if (event.titleId != null) {
      final title = await repo.getTitle(event.titleId!);
      if (title == null) return;
      final items = await _getResolvedItems(title.id);
      emit(
        CustomTitleEditorLoadedState(
          title: title,
          entries: items.map(_entry).toList(),
        ),
      );
      return;
    }

    if (event.fromOriginalTitleId != null) {
      final items = await _getItemsFromOriginalTitle(event.fromOriginalTitleId!);
      final entries = (await repo.resolveItems(items)).map(_entry).toList();
      emit(
        CustomTitleEditorLoadedState(
          title: CustomTitle(
            name: event.suggestedName ?? "",
            sourceTitleId: event.fromOriginalTitleId,
          ),
          entries: entries,
          isDirty: true,
        ),
      );
      return;
    }

    emit(
      const CustomTitleEditorLoadedState(
        title: CustomTitle(name: ""),
        entries: [],
      ),
    );
  }

  CustomTitleEditorLoadedState? get _loaded {
    final s = state;
    return s is CustomTitleEditorLoadedState ? s : null;
  }

  void _nameChanged(
    CustomTitleEditorNameChangedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    emit(s.copyWith(title: s.title.copyWith(name: event.name), isDirty: true));
  }

  void _descriptionChanged(
    CustomTitleEditorDescriptionChangedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    emit(s.copyWith(title: s.title.copyWith(description: event.description), isDirty: true));
  }

  void _reorder(
    CustomTitleEditorItemsReorderedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    final entries = List<EditorEntry>.from(s.entries);
    var newIndex = event.newIndex;
    if (event.oldIndex < newIndex) newIndex -= 1;
    entries.insert(newIndex, entries.removeAt(event.oldIndex));
    emit(s.copyWith(entries: entries, isDirty: true));
  }

  void _countChanged(
    CustomTitleEditorItemCountChangedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    final count = event.count.clamp(1, 9999);
    emit(
      s.copyWith(
        entries: [
          for (final e in s.entries)
            if (e.uid == event.uid) e.withCount(count) else e,
        ],
        isDirty: true,
      ),
    );
  }

  Future<void> _remove(
    CustomTitleEditorItemRemovedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    final s = _loaded;
    if (s == null) return;
    // Emit before any await so later events (e.g. save) see this change.
    emit(
      s.copyWith(
        entries: s.entries.where((e) => e.uid != event.uid).toList(),
        isDirty: true,
      ),
    );
    for (final e in s.entries.where((e) => e.uid == event.uid)) {
      await _dropDraftFile(e.resolved.item.audioFile);
    }
  }

  /// Deletes a recording made in this session that is no longer used. Recordings that
  /// were already saved stay on disk until the title is saved, so leaving the editor
  /// without saving never loses them.
  Future<void> _dropDraftFile(String? fileName) async {
    if (fileName == null || !_draftFiles.contains(fileName) || _savedFiles.contains(fileName)) {
      return;
    }
    _draftFiles.remove(fileName);
    audioStorage.unpin(fileName);
    await audioStorage.delete(fileName);
  }

  Future<void> _audioChanged(
    CustomTitleEditorItemAudioChangedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    final s = _loaded;
    if (s == null) return;

    final newFile = event.audioFile;
    if (newFile != null) {
      _draftFiles.add(newFile);
      audioStorage.pin(newFile);
    }
    // Emit before any await so later events (e.g. save) see this change.
    emit(
      s.copyWith(
        entries: [
          for (final e in s.entries)
            if (e.uid == event.uid) e.withAudio(newFile) else e,
        ],
        isDirty: true,
      ),
    );
    for (final e in s.entries.where((e) => e.uid == event.uid)) {
      final old = e.resolved.item.audioFile;
      if (old != newFile) await _dropDraftFile(old);
    }
  }

  ResolvedTitleItem _fromCustomZikr(CustomZikr z) {
    return ResolvedTitleItem(
      item: CustomTitleItem(
        kind: CustomItemKind.custom,
        refId: z.id,
        count: z.defaultCount,
      ),
      content: z.content,
      source: z.source,
      fadl: z.fadl,
    );
  }

  void _addCustomZikrs(
    CustomTitleEditorCustomZikrsAddedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    emit(
      s.copyWith(
        entries: [...s.entries, ...event.zikrs.map((z) => _entry(_fromCustomZikr(z)))],
        isDirty: true,
      ),
    );
  }

  Future<void> _addOriginalZikrs(
    CustomTitleEditorOriginalZikrsAddedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    final s = _loaded;
    if (s == null) return;

    final items = <CustomTitleItem>[];
    for (final id in event.contentIds) {
      final item = await _getItemFromOriginalZikr(id);
      if (item != null) items.add(item);
    }
    final resolved = await repo.resolveItems(items);

    final current = _loaded;
    if (current == null) return;
    emit(
      current.copyWith(
        entries: [...current.entries, ...resolved.map(_entry)],
        isDirty: true,
      ),
    );
  }

  /// A custom zikr was edited in the library: refresh its rows in the draft.
  void _customZikrChanged(
    CustomTitleEditorCustomZikrChangedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) {
    final s = _loaded;
    if (s == null) return;
    final z = event.zikr;
    emit(
      s.copyWith(
        entries: [
          for (final e in s.entries)
            if (e.resolved.item.kind == CustomItemKind.custom && e.resolved.item.refId == z.id)
              EditorEntry(
                uid: e.uid,
                resolved: ResolvedTitleItem(
                  item: e.resolved.item,
                  content: z.content,
                  source: z.source,
                  fadl: z.fadl,
                ),
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> _customZikrDeleted(
    CustomTitleEditorCustomZikrDeletedEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    final s = _loaded;
    if (s == null) return;
    for (final e in s.entries) {
      if (e.resolved.item.kind == CustomItemKind.custom && e.resolved.item.refId == event.zikrId) {
        await _dropDraftFile(e.resolved.item.audioFile);
      }
    }
    emit(
      s.copyWith(
        entries: s.entries
            .where(
              (e) =>
                  !(e.resolved.item.kind == CustomItemKind.custom &&
                      e.resolved.item.refId == event.zikrId),
            )
            .toList(),
      ),
    );
  }

  Future<void> _save(
    CustomTitleEditorSaveEvent event,
    Emitter<CustomTitleEditorState> emit,
  ) async {
    final s = _loaded;
    if (s == null || s.isSaving) return;

    emit(s.copyWith(isSaving: true, error: () => null));

    try {
      final items = [for (final e in s.entries) e.toItemForSaving()];
      // Recordings no longer used must not be pinned, or the cleanup that runs while
      // saving would keep them.
      final used = {for (final i in items.where((i) => i.hasUserAudio)) i.audioFile!};
      for (final file in _draftFiles.where((f) => !used.contains(f)).toList()) {
        _draftFiles.remove(file);
        audioStorage.unpin(file);
      }
      final id = await _saveTitle(s.title, items);
      _savedFiles
        ..clear()
        ..addAll(items.where((i) => i.hasUserAudio).map((i) => i.audioFile!));
      emit(
        s.copyWith(title: s.title.copyWith(id: id), isSaving: false, saved: true, isDirty: false),
      );
    } on CustomTitleValidationException catch (e) {
      emit(s.copyWith(isSaving: false, error: () => e.error));
    }
  }

  @override
  Future<void> close() async {
    // Recordings of an abandoned draft must not stay on disk.
    for (final file in _draftFiles.toList()) {
      audioStorage.unpin(file);
      if (!_savedFiles.contains(file)) await audioStorage.delete(file);
    }
    return super.close();
  }
}
