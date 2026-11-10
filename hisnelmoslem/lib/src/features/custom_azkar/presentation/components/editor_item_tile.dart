import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_title_editor/custom_title_editor_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/count_stepper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/zikr_preview_text.dart';

/// One reorderable row of the title editor.
class EditorItemTile extends StatelessWidget {
  final EditorEntry entry;
  final int index;

  const EditorItemTile({super.key, required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = entry.resolved;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: S.of(context).dragToReorder,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.drag_indicator_rounded),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZikrPreviewText(content: resolved.content),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      EditorItemBadge(item: resolved),
                      CountStepper(
                        value: entry.count,
                        onChanged: (count) => context.read<CustomTitleEditorBloc>().add(
                          CustomTitleEditorItemCountChangedEvent(uid: entry.uid, count: count),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: S.of(context).removeFromTitle,
              color: theme.colorScheme.error,
              onPressed: () => context.read<CustomTitleEditorBloc>().add(
                CustomTitleEditorItemRemovedEvent(entry.uid),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip telling where a zikr comes from (original, custom or saved copy).
class EditorItemBadge extends StatelessWidget {
  final ResolvedTitleItem item;
  const EditorItemBadge({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (label, icon) = switch ((item.item.kind, item.isFromSnapshot)) {
      (CustomItemKind.custom, _) => (s.customBadge, Icons.edit_note_rounded),
      (CustomItemKind.original, true) => (s.savedCopyBadge, Icons.history_rounded),
      (CustomItemKind.original, false) => (s.originalBadge, Icons.menu_book_rounded),
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label),
      padding: EdgeInsets.zero,
    );
  }
}
