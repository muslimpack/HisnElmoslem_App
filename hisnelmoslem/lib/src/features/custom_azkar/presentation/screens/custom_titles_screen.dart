import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_card.dart';

/// Home dashboard tab listing the user's custom titles.
class CustomTitlesScreen extends StatelessWidget {
  const CustomTitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
      builder: (context, state) {
        if (state is! CustomTitlesLoadedState) return const Loading();

        if (state.titles.isEmpty) {
          return Empty(
            isImage: false,
            icon: Icons.edit_note_rounded,
            title: S.of(context).customAzkarEmptyTitle,
            description: S.of(context).customAzkarEmptyDesc,
          );
        }

        return ListView.builder(
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
        );
      },
    );
  }
}
