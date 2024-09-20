import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
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
          if (dbTitle.favourite)
            IconButton(
              tooltip: S.of(context).bookmark,
              icon: Icon(
                Icons.bookmark_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                sl<HomeBloc>().add(
                  HomeToggleTitleBookmarkEvent(
                    title: dbTitle,
                    bookmark: false,
                  ),
                );
              },
            )
          else
            IconButton(
              tooltip: S.of(context).bookmark,
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                sl<HomeBloc>().add(
                  HomeToggleTitleBookmarkEvent(
                    title: dbTitle,
                    bookmark: true,
                  ),
                );
              },
            ),
        ],
      ),
      trailing: dbAlarm == null
          ? IconButton(
              icon: const Icon(Icons.alarm_add_rounded),
              onPressed: () async {
                final DbAlarm? editedAlarm = await showAlarmEditorDialog(
                  context: context,
                  dbAlarm: alarm,
                  isToEdit: false,
                );

                if (editedAlarm == null) return;
                if (!context.mounted) return;

                context.read<AlarmsBloc>().add(AlarmsAddEvent(editedAlarm));
              },
            )
          : GestureDetector(
              onLongPress: () async {
                final DbAlarm? editedAlarm = await showAlarmEditorDialog(
                  context: context,
                  dbAlarm: alarm,
                  isToEdit: true,
                );

                if (editedAlarm == null) return;
                if (!context.mounted) return;

                context.read<AlarmsBloc>().add(AlarmsEditEvent(editedAlarm));
              },
              child: alarm.isActive
                  ? IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        context.read<AlarmsBloc>().add(
                              AlarmsEditEvent(
                                alarm.copyWith(isActive: false),
                              ),
                            );
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.notifications_off,
                      ),
                      onPressed: () {
                        context.read<AlarmsBloc>().add(
                              AlarmsEditEvent(
                                alarm.copyWith(isActive: true),
                              ),
                            );
                      },
                    ),
            ),

      title: Text(
        dbTitle.name,
      ),
      // trailing: Text(zikrList[index]),
      onTap: () {
        context.push(
          ZikrViewerScreen(index: dbTitle.id),
        );
      },
    );
  }
}
