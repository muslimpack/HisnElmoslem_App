part of 'custom_title_editor_bloc.dart';

/// One row in the editor. [uid] is stable for the editor session so duplicates
/// of the same zikr can be told apart (and used as widget keys).
class EditorEntry extends Equatable {
  final int uid;
  final ResolvedTitleItem resolved;

  const EditorEntry({required this.uid, required this.resolved});

  int get count => resolved.item.count;

  EditorEntry withCount(int count) {
    return EditorEntry(
      uid: uid,
      resolved: ResolvedTitleItem(
        item: resolved.item.copyWith(count: count),
        content: resolved.content,
        source: resolved.source,
        fadl: resolved.fadl,
        hokm: resolved.hokm,
        audio: resolved.audio,
        isFromSnapshot: resolved.isFromSnapshot,
      ),
    );
  }

  EditorEntry withAudio(String? audioFile) {
    return EditorEntry(
      uid: uid,
      resolved: ResolvedTitleItem(
        item: audioFile == null
            ? resolved.item.copyWith(clearAudio: true)
            : resolved.item.copyWith(audioFile: audioFile),
        content: resolved.content,
        source: resolved.source,
        fadl: resolved.fadl,
        hokm: resolved.hokm,
        audio: resolved.audio,
        isFromSnapshot: resolved.isFromSnapshot,
      ),
    );
  }

  /// Refreshes the stored snapshot from the live text of original zikrs.
  CustomTitleItem toItemForSaving() {
    final item = resolved.item;
    if (item.kind == CustomItemKind.original && !resolved.isFromSnapshot) {
      return item.copyWith(
        snapshot: ZikrSnapshot(
          content: resolved.content,
          source: resolved.source,
          fadl: resolved.fadl,
          hokm: resolved.hokm,
        ),
      );
    }
    return item;
  }

  @override
  List<Object> get props => [uid, resolved];
}

sealed class CustomTitleEditorState extends Equatable {
  const CustomTitleEditorState();

  @override
  List<Object?> get props => [];
}

final class CustomTitleEditorLoadingState extends CustomTitleEditorState {
  const CustomTitleEditorLoadingState();
}

final class CustomTitleEditorLoadedState extends CustomTitleEditorState {
  final CustomTitle title;
  final List<EditorEntry> entries;
  final bool isDirty;
  final bool isSaving;
  final bool saved;
  final CustomTitleError? error;

  const CustomTitleEditorLoadedState({
    required this.title,
    required this.entries,
    this.isDirty = false,
    this.isSaving = false,
    this.saved = false,
    this.error,
  });

  bool get isNew => title.id == 0;

  CustomTitleEditorLoadedState copyWith({
    CustomTitle? title,
    List<EditorEntry>? entries,
    bool? isDirty,
    bool? isSaving,
    bool? saved,
    CustomTitleError? Function()? error,
  }) {
    return CustomTitleEditorLoadedState(
      title: title ?? this.title,
      entries: entries ?? this.entries,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [title, entries, isDirty, isSaving, saved, error];
}
