import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/mappers/custom_alarm_mapper.dart';

/// Per-title reminder control. Same interaction as the original title alarm button:
/// tap toggles, long press opens the editor (edit / delete).
class CustomTitleAlarmButton extends StatelessWidget {
  final CustomTitle title;
  final CustomAlarm? alarm;

  const CustomTitleAlarmButton({super.key, required this.title, required this.alarm});

  @override
  Widget build(BuildContext context) {
    final current = alarm;

    if (current == null) {
      return IconButton(
        icon: const Icon(Icons.alarm_add_rounded),
        onPressed: () async {
          final bloc = context.read<CustomTitlesBloc>();
          final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
            context: context,
            dbAlarm: DbAlarm(titleId: title.id, title: title.name),
            isToEdit: false,
          );
          if (result == null) return;
          bloc.add(
            CustomAlarmSavedEvent(alarm: result.value.toCustomAlarm(), titleName: title.name),
          );
        },
      );
    }

    return GestureDetector(
      onLongPress: () async {
        final bloc = context.read<CustomTitlesBloc>();
        final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
          context: context,
          dbAlarm: current.toDbAlarm(title.name),
          isToEdit: true,
        );
        if (result == null) return;
        switch (result.action) {
          case EditorActionEnum.edit:
            bloc.add(
              CustomAlarmSavedEvent(alarm: result.value.toCustomAlarm(), titleName: title.name),
            );
          case EditorActionEnum.delete:
            bloc.add(CustomAlarmRemovedEvent(title.id));
          default:
        }
      },
      child: IconButton(
        icon: current.isActive
            ? Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary)
            : const Icon(Icons.notifications_off),
        onPressed: () {
          context.read<CustomTitlesBloc>().add(
            CustomAlarmSavedEvent(
              alarm: current.copyWith(isActive: !current.isActive),
              titleName: title.name,
            ),
          );
        },
      ),
    );
  }
}
