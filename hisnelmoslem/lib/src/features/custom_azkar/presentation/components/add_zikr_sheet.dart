import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_title_editor/custom_title_editor_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_zikr_picker/custom_zikr_picker_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_zikr_form_sheet.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/zikr_preview_text.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/no_items_found_indicator_builder.dart';

/// Bottom sheet used by the editor to add zikrs to the draft title.
class AddZikrSheet extends StatelessWidget {
  const AddZikrSheet({super.key});

  /// [editorBloc] receives the chosen zikrs.
  static Future<void> show(
    BuildContext context, {
    required CustomTitleEditorBloc editorBloc,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: editorBloc),
          BlocProvider(create: (_) => sl<CustomZikrPickerCubit>()..load()),
        ],
        child: const FractionallySizedBox(heightFactor: 0.9, child: AddZikrSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: s.newZikr),
              Tab(text: s.myZikrs),
              Tab(text: s.fromHisn),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [NewZikrTab(), MyZikrsTab(), HisnZikrsTab()],
            ),
          ),
          const AddSelectedBar(),
        ],
      ),
    );
  }
}

/// Footer that adds the ticked library / Hisn zikrs to the draft title.
class AddSelectedBar extends StatelessWidget {
  const AddSelectedBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomZikrPickerCubit, CustomZikrPickerState>(
      builder: (context, state) {
        if (state.selectedCount == 0) return const SizedBox.shrink();

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text(S.of(context).addSelected(state.selectedCount)),
                onPressed: () {
                  final editor = context.read<CustomTitleEditorBloc>();
                  final customZikrs = state.customZikrs
                      .where((z) => state.selectedCustomIds.contains(z.id))
                      .toList();
                  if (customZikrs.isNotEmpty) {
                    editor.add(CustomTitleEditorCustomZikrsAddedEvent(customZikrs));
                  }
                  if (state.selectedOriginalIds.isNotEmpty) {
                    editor.add(
                      CustomTitleEditorOriginalZikrsAddedEvent(state.selectedOriginalIds.toList()),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tab 1: write a brand new zikr, save it to the library and add it right away.
class NewZikrTab extends StatelessWidget {
  const NewZikrTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Empty(
      isImage: false,
      icon: Icons.edit_note_rounded,
      title: s.newZikr,
      buttonText: s.addZikr,
      onButtonCLick: () async {
        final picker = context.read<CustomZikrPickerCubit>();
        final editor = context.read<CustomTitleEditorBloc>();
        final navigator = Navigator.of(context);

        final result = await CustomZikrForm.show(context);
        if (result == null) return;

        final saved = await picker.saveZikr(result);
        editor.add(CustomTitleEditorCustomZikrsAddedEvent([saved]));
        navigator.pop();
      },
    );
  }
}

/// Tab 2: the user's zikr library.
class MyZikrsTab extends StatelessWidget {
  const MyZikrsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomZikrPickerCubit, CustomZikrPickerState>(
      builder: (context, state) {
        if (state.isLoading) return const Loading();
        if (state.customZikrs.isEmpty) {
          return Empty(
            isImage: false,
            icon: Icons.menu_book_outlined,
            title: S.of(context).noCustomZikrs,
          );
        }

        return ListView.builder(
          itemCount: state.customZikrs.length,
          itemBuilder: (context, index) {
            final zikr = state.customZikrs[index];
            return LibraryZikrTile(
              key: ValueKey(zikr.id),
              zikr: zikr,
              selected: state.selectedCustomIds.contains(zikr.id),
            );
          },
        );
      },
    );
  }
}

class LibraryZikrTile extends StatelessWidget {
  final CustomZikr zikr;
  final bool selected;

  const LibraryZikrTile({super.key, required this.zikr, required this.selected});

  @override
  Widget build(BuildContext context) {
    final picker = context.read<CustomZikrPickerCubit>();

    return CheckboxListTile(
      value: selected,
      onChanged: (_) => picker.toggleCustom(zikr.id),
      title: ZikrPreviewText(content: zikr.content, maxLines: 2),
      secondary: PopupMenuButton<String>(
        onSelected: (action) async {
          final editor = context.read<CustomTitleEditorBloc>();
          if (action == "edit") {
            final result = await CustomZikrForm.show(context, zikr: zikr);
            if (result == null) return;
            final saved = await picker.saveZikr(result);
            editor.add(CustomTitleEditorCustomZikrChangedEvent(saved));
          } else {
            final titles = await picker.titlesUsing(zikr.id);
            if (!context.mounted) return;
            final confirm = await YesOrNoDialog.show(
              context,
              msg: S.of(context).deleteCustomZikrConfirm,
              details: titles.isEmpty
                  ? null
                  : S.of(context).deleteCustomZikrUsedIn(titles.join("، ")),
            );
            if (confirm ?? false) {
              await picker.deleteZikr(zikr.id);
              editor.add(CustomTitleEditorCustomZikrDeletedEvent(zikr.id));
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: "edit", child: Text(S.of(context).edit)),
          PopupMenuItem(value: "delete", child: Text(S.of(context).delete)),
        ],
      ),
    );
  }
}

/// Tab 3: search the bundled Hisn al-Muslim zikrs (read-only).
class HisnZikrsTab extends StatelessWidget {
  const HisnZikrsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: context.read<CustomZikrPickerCubit>().search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: S.of(context).searchHisnHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomZikrPickerCubit, CustomZikrPickerState>(
            builder: (context, state) {
              if (state.query.isEmpty) {
                return const Empty(isImage: false, icon: Icons.search_rounded, iconSize: 64);
              }
              if (state.originalResults.isEmpty) {
                return NoItemsFoundIndicatorBuilder(searchText: state.query);
              }
              return ListView.builder(
                itemCount: state.originalResults.length,
                itemBuilder: (context, index) {
                  final zikr = state.originalResults[index];
                  return CheckboxListTile(
                    key: ValueKey(zikr.id),
                    value: state.selectedOriginalIds.contains(zikr.id),
                    onChanged: (_) => context.read<CustomZikrPickerCubit>().toggleOriginal(zikr.id),
                    title: ZikrPreviewText(content: zikr.content),
                    subtitle: zikr.source.isEmpty
                        ? null
                        : Text(zikr.source, maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
