import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/create_title_sheet.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_card.dart';

/// Home dashboard tab listing the user's custom titles.
class CustomTitlesScreen extends StatelessWidget {
  const CustomTitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
      builder: (context, state) {
        if (state is! CustomTitlesLoadedState) return const Loading();

        return Column(
          children: [
            const CreateCustomTitleButton(),
            Expanded(
              child: state.titles.isEmpty
                  ? Empty(
                      isImage: false,
                      icon: Icons.edit_note_rounded,
                      title: S.of(context).customAzkarEmptyTitle,
                      description: S.of(context).customAzkarEmptyDesc,
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: state.titles.length,
                      itemBuilder: (context, index) {
                        final title = state.titles[index];
                        return CustomTitleCard(
                          key: ValueKey(title.id),
                          title: title,
                          hasActiveAlarm: state.hasActiveAlarm(title.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Full-width "New title" action pinned above the list.
class CreateCustomTitleButton extends StatelessWidget {
  const CreateCustomTitleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: () => showCreateTitleSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(S.of(context).newCustomTitle),
        ),
      ),
    );
  }
}
