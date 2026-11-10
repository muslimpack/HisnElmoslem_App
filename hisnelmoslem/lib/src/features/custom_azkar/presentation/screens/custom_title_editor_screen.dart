import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/usecases/custom_azkar_usecases.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_title_editor/custom_title_editor_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/add_zikr_sheet.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/editor_item_tile.dart';

/// Create ([titleId] null) or edit a custom title. Pass [fromOriginalTitleId]
/// to start from a Hisn al-Muslim title's zikrs (copied as references).
class CustomTitleEditorScreen extends StatelessWidget {
  final int? titleId;
  final int? fromOriginalTitleId;
  final String? suggestedName;

  const CustomTitleEditorScreen({
    super.key,
    this.titleId,
    this.fromOriginalTitleId,
    this.suggestedName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomTitleEditorBloc>()
        ..add(
          CustomTitleEditorStartEvent(
            titleId: titleId,
            fromOriginalTitleId: fromOriginalTitleId,
            suggestedName: suggestedName,
          ),
        ),
      child: const CustomTitleEditorView(),
    );
  }
}

class CustomTitleEditorView extends StatelessWidget {
  const CustomTitleEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomTitleEditorBloc, CustomTitleEditorState>(
      listenWhen: (previous, current) =>
          current is CustomTitleEditorLoadedState &&
          (current.saved || current.error != previous.maybeError),
      listener: (context, state) {
        if (state is! CustomTitleEditorLoadedState) return;

        if (state.saved) {
          context.read<CustomTitlesBloc>().add(const CustomTitlesRefreshEvent());
          Navigator.of(context).pop();
          return;
        }

        final s = S.of(context);
        final message = switch (state.error) {
          CustomTitleError.emptyName => s.titleNameRequired,
          CustomTitleError.noItems => s.noItemsInTitle,
          null => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        if (state is! CustomTitleEditorLoadedState) {
          return const Scaffold(body: Loading());
        }

        return PopScope(
          canPop: !state.isDirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final navigator = Navigator.of(context);
            final discard = await YesOrNoDialog.show(
              context,
              msg: S.of(context).discardChangesTitle,
              details: S.of(context).discardChangesDetails,
            );
            if (discard ?? false) navigator.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                state.isNew ? S.of(context).newCustomTitle : S.of(context).editCustomTitle,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<CustomTitleEditorBloc>().add(
                            const CustomTitleEditorSaveEvent(),
                          ),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(S.of(context).save),
                  ),
                ),
              ],
            ),
            body: const EditorItemsList(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => AddZikrSheet.show(
                context,
                editorBloc: context.read<CustomTitleEditorBloc>(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(S.of(context).addZikr),
            ),
          ),
        );
      },
    );
  }
}

extension on CustomTitleEditorState {
  CustomTitleError? get maybeError {
    final s = this;
    return s is CustomTitleEditorLoadedState ? s.error : null;
  }
}

/// Name / description fields followed by the reorderable list of zikrs.
class EditorItemsList extends StatelessWidget {
  const EditorItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitleEditorBloc, CustomTitleEditorState>(
      buildWhen: (previous, current) =>
          current is CustomTitleEditorLoadedState &&
          (previous is! CustomTitleEditorLoadedState || previous.entries != current.entries),
      builder: (context, state) {
        if (state is! CustomTitleEditorLoadedState) return const Loading();

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          header: const EditorHeaderFields(),
          footer: state.entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: SizedBox(
                    height: 220,
                    child: Empty(
                      isImage: false,
                      icon: Icons.playlist_add_rounded,
                      title: S.of(context).noItemsInTitle,
                    ),
                  ),
                )
              : null,
          itemCount: state.entries.length,
          // ignore: deprecated_member_use, onReorderItem needs a newer Flutter than the pinned one.
          onReorder: (oldIndex, newIndex) => context.read<CustomTitleEditorBloc>().add(
            CustomTitleEditorItemsReorderedEvent(oldIndex: oldIndex, newIndex: newIndex),
          ),
          itemBuilder: (context, index) {
            final entry = state.entries[index];
            return EditorItemTile(key: ValueKey(entry.uid), entry: entry, index: index);
          },
        );
      },
    );
  }
}

/// Owns the text controllers; the bloc only receives changes.
class EditorHeaderFields extends StatefulWidget {
  const EditorHeaderFields({super.key});

  @override
  State<EditorHeaderFields> createState() => _EditorHeaderFieldsState();
}

class _EditorHeaderFieldsState extends State<EditorHeaderFields> {
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final state = context.read<CustomTitleEditorBloc>().state;
    final title = state is CustomTitleEditorLoadedState ? state.title : null;
    _name = TextEditingController(text: title?.name);
    _description = TextEditingController(text: title?.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bloc = context.read<CustomTitleEditorBloc>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            onChanged: (value) => bloc.add(CustomTitleEditorNameChangedEvent(value)),
            decoration: InputDecoration(
              labelText: s.customTitleName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 1,
            maxLines: 3,
            onChanged: (value) => bloc.add(CustomTitleEditorDescriptionChangedEvent(value)),
            decoration: InputDecoration(
              labelText: s.customTitleDescription,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
