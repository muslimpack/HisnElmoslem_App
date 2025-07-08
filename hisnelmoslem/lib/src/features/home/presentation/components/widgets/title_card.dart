import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/components/bookmark_title_button.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';

class TitleCard extends StatelessWidget {
  final Color? titleColor;
  final DbTitle dbTitle;
  final DbAlarm? dbAlarm;

  const TitleCard({
    super.key,
    required this.dbTitle,
    required this.dbAlarm,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final DbAlarm alarm =
        dbAlarm ?? DbAlarm(titleId: dbTitle.id, title: dbTitle.name);

    return ListTile(
      tileColor: titleColor,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 25),
                child: Text(dbTitle.order.toString()),
              ),
            ),
          ),
          BookmarkTitleButton(titleId: dbTitle.id),
        ],
      ),

      ///TODO remove when desktop notification is ready
      trailing: PlatformExtension.isDesktop
          ? null
          : _TitleCardAlarmButton(alarm: alarm, dbAlarm: dbAlarm),
      title: Text(dbTitle.name),
      onTap: () {
        context.push(ZikrViewerScreen(index: dbTitle.id));
      },
    );
  }
}

class _TitleCardAlarmButton extends StatelessWidget {
  final DbAlarm alarm;
  final DbAlarm? dbAlarm;
  const _TitleCardAlarmButton({required this.alarm, this.dbAlarm});

  @override
  Widget build(BuildContext context) {
    return dbAlarm == null
        ? IconButton(
            icon: const Icon(Icons.alarm_add_rounded),
            onPressed: () async {
              final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
                context: context,
                dbAlarm: alarm,
                isToEdit: false,
              );

              if (result == null) return;
              if (!context.mounted) return;

              context.read<AlarmsBloc>().add(AlarmsAddEvent(result.value));
            },
          )
        : GestureDetector(
            onLongPress: () async {
              final EditorResult<DbAlarm>? result = await showAlarmEditorDialog(
                context: context,
                dbAlarm: alarm,
                isToEdit: true,
              );

              if (result == null) return;
              if (!context.mounted) return;
              switch (result.action) {
                case EditorActionEnum.edit:
                  context.read<AlarmsBloc>().add(AlarmsEditEvent(result.value));
                case EditorActionEnum.delete:
                  context.read<AlarmsBloc>().add(
                    AlarmsRemoveEvent(result.value),
                  );
                default:
              }
            },
            child: alarm.isActive
                ? IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      context.read<AlarmsBloc>().add(
                        AlarmsEditEvent(alarm.copyWith(isActive: false)),
                      );
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.notifications_off),
                    onPressed: () {
                      context.read<AlarmsBloc>().add(
                        AlarmsEditEvent(alarm.copyWith(isActive: true)),
                      );
                    },
                  ),
          );
  }
}
