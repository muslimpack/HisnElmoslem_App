import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/custom_title_favourite_button.dart';

class CustomTitleCard extends StatelessWidget {
  final CustomTitle title;
  final bool hasActiveAlarm;
  final VoidCallback? onTap;

  const CustomTitleCard({
    super.key,
    required this.title,
    this.hasActiveAlarm = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CustomTitleFavouriteButton(
        titleId: title.id,
        isFavourite: title.isFavourite,
      ),
      title: Text(title.name),
      subtitle: Row(
        children: [
          Text(S.of(context).customItemsCount(title.itemCount)),
          if (hasActiveAlarm) ...[
            const SizedBox(width: 12),
            Icon(Icons.alarm_on_rounded, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              S.of(context).customTitleHasReminder,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ],
      ),
      trailing: CustomTitleMenuButton(title: title),
    );
  }
}

class CustomTitleMenuButton extends StatelessWidget {
  final CustomTitle title;
  const CustomTitleMenuButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CustomTitleAction>(
      onSelected: (action) async {
        switch (action) {
          case _CustomTitleAction.delete:
            final bloc = context.read<CustomTitlesBloc>();
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => YesOrNoDialog(
                msg: S.of(context).customTitleDeleteConfirm,
                details: S.of(context).customTitleDeleteDetails,
              ),
            );
            if (confirm ?? false) bloc.add(CustomTitlesDeleteEvent(title.id));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _CustomTitleAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(S.of(context).delete),
          ),
        ),
      ],
    );
  }
}

enum _CustomTitleAction { delete }
