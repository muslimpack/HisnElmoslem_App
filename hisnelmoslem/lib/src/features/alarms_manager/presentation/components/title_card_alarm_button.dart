// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';

class TitleCardAlarmButton extends StatelessWidget {
  final DbTitle dbTitle;
  const TitleCardAlarmButton({super.key, required this.dbTitle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        if (state is! AlarmsLoadedState) {
          return const SizedBox.shrink();
        }

        final bool hasAlarm = state.alarms.any(
          (element) => element.titleId == dbTitle.id,
        );

        if (!hasAlarm) {
          return IconButton(
            icon: const Icon(Icons.alarm_add_rounded),
            onPressed: () async {
              final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
                context: context,
                dbAlarm: DbAlarm(titleId: dbTitle.id, title: dbTitle.name),
                isToEdit: false,
              );

              if (result == null) return;
              if (!context.mounted) return;

              context.read<AlarmsBloc>().add(AlarmsAddEvent(result.value));
            },
          );
        }

        final DbAlarm dbAlarm = state.alarms.firstWhere(
          (element) => element.titleId == dbTitle.id,
        );

        return GestureDetector(
          onLongPress: () async {
            final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
              context: context,
              dbAlarm: dbAlarm,
              isToEdit: true,
            );

            if (result == null) return;
            if (!context.mounted) return;
            switch (result.action) {
              case EditorActionEnum.edit:
                context.read<AlarmsBloc>().add(AlarmsEditEvent(result.value));
              case EditorActionEnum.delete:
                context.read<AlarmsBloc>().add(AlarmsRemoveEvent(result.value));
              default:
            }
          },
          child: dbAlarm.isActive
              ? IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    context.read<AlarmsBloc>().add(
                      AlarmsEditEvent(dbAlarm.copyWith(isActive: false)),
                    );
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.notifications_off),
                  onPressed: () {
                    context.read<AlarmsBloc>().add(
                      AlarmsEditEvent(dbAlarm.copyWith(isActive: true)),
                    );
                  },
                ),
        );
      },
    );
  }
}
