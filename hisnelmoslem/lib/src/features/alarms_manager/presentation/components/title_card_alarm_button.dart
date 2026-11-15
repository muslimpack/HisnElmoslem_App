// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_time_chip.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';

class TitleCardAlarmButton extends StatelessWidget {
  final DbTitle dbTitle;
  const TitleCardAlarmButton({super.key, required this.dbTitle});

  Future<void> _openEditor(
    BuildContext context, {
    required DbAlarm dbAlarm,
    required bool isToEdit,
  }) async {
    final bloc = context.read<AlarmsBloc>();
    final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
      context: context,
      dbAlarm: dbAlarm,
      isToEdit: isToEdit,
    );
    if (result == null) return;

    if (!isToEdit) {
      bloc.add(AlarmsAddEvent(result.value));
      return;
    }
    switch (result.action) {
      case EditorActionEnum.edit:
        bloc.add(AlarmsEditEvent(result.value));
      case EditorActionEnum.delete:
        bloc.add(AlarmsRemoveEvent(result.value));
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        if (state is! AlarmsLoadedState) {
          return const SizedBox.shrink();
        }

        final DbAlarm? dbAlarm = state.alarms
            .where((element) => element.titleId == dbTitle.id)
            .firstOrNull;

        if (dbAlarm == null) {
          return IconButton(
            tooltip: S.of(context).addReminder,
            icon: const Icon(Icons.alarm_add_rounded),
            onPressed: () => _openEditor(
              context,
              dbAlarm: DbAlarm(titleId: dbTitle.id, title: dbTitle.name),
              isToEdit: false,
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AlarmTimeChip(
              hour: dbAlarm.hour,
              minute: dbAlarm.minute,
              isActive: dbAlarm.isActive,
              onTap: () => _openEditor(context, dbAlarm: dbAlarm, isToEdit: true),
            ),
            GestureDetector(
              onLongPress: () => _openEditor(context, dbAlarm: dbAlarm, isToEdit: true),
              child: IconButton(
                icon: dbAlarm.isActive
                    ? Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const Icon(Icons.notifications_off),
                onPressed: () {
                  context.read<AlarmsBloc>().add(
                    AlarmsEditEvent(dbAlarm.copyWith(isActive: !dbAlarm.isActive)),
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
