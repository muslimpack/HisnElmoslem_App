import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/screens/custom_title_editor_screen.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';

/// Entry point for creating a title: from scratch or from an existing Hisn title.
class CreateTitleSheet extends StatelessWidget {
  /// Context that stays mounted after the sheet closes (used for navigation).
  final BuildContext parentContext;
  const CreateTitleSheet({super.key, required this.parentContext});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => CreateTitleSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.note_add_outlined)),
            title: Text(s.createFromScratch),
            subtitle: Text(s.createFromScratchDesc),
            onTap: () {
              Navigator.pop(context);
              parentContext.push(const CustomTitleEditorScreen());
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.copy_all_rounded)),
            title: Text(s.createFromExisting),
            subtitle: Text(s.createFromExistingDesc),
            onTap: () async {
              Navigator.pop(context);
              final DbTitle? picked = await OriginalTitlePicker.show(parentContext);
              if (picked != null && parentContext.mounted) {
                parentContext.push(
                  CustomTitleEditorScreen(
                    fromOriginalTitleId: picked.id,
                    suggestedName: picked.name,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Searchable list of the Hisn al-Muslim titles. Pops with the chosen [DbTitle].
class OriginalTitlePicker extends StatefulWidget {
  const OriginalTitlePicker({super.key});

  static Future<DbTitle?> show(BuildContext context) {
    return showModalBottomSheet<DbTitle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeBloc>(),
        child: const FractionallySizedBox(heightFactor: 0.9, child: OriginalTitlePicker()),
      ),
    );
  }

  @override
  State<OriginalTitlePicker> createState() => _OriginalTitlePickerState();
}

class _OriginalTitlePickerState extends State<OriginalTitlePicker> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    if (state is! HomeLoadedState) return const SizedBox.shrink();

    final titles = state.titles.where((t) => t.name.contains(_query.trim())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: S.of(context).chooseOriginalTitle,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final title = titles[index];
              return ListTile(
                key: ValueKey(title.id),
                leading: CircleAvatar(child: Text(title.order.toString())),
                title: Text(title.name),
                onTap: () => Navigator.pop<DbTitle>(context, title),
              );
            },
          ),
        ),
      ],
    );
  }
}
