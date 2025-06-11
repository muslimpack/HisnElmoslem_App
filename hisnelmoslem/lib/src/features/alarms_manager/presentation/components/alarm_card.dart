import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_editor.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:intl/intl.dart';

class AlarmCard extends StatelessWidget {
  final DbAlarm dbAlarm;

  const AlarmCard({super.key, required this.dbAlarm});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: .3,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.green.withOpacity(.5),
            onPressed: (val) async {
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
                  context.read<AlarmsBloc>().add(
                    AlarmsRemoveEvent(result.value),
                  );
                default:
              }
            },
            icon: Icons.edit,
            label: S.of(context).edit,
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: .3,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (val) {
              context.read<AlarmsBloc>().add(AlarmsRemoveEvent(dbAlarm));
            },
            backgroundColor: Colors.red.withOpacity(.5),
            icon: Icons.delete,
            label: S.of(context).delete,
          ),
        ],
      ),
      child: AlarmCardBody(dbAlarm: dbAlarm, context: context),
    );
  }
}

class AlarmCardBody extends StatelessWidget {
  const AlarmCardBody({
    super.key,
    required this.dbAlarm,
    required this.context,
  });

  final DbAlarm dbAlarm;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.alarm),
          title: Text(dbAlarm.title),
          subtitle: Wrap(
            children: [
              if (dbAlarm.body.isNotEmpty)
                RoundTagCard(
                  name: dbAlarm.body,
                  color: Colors.brown.withOpacity(.5),
                ),
              Row(
                children: [
                  Expanded(
                    child: RoundTagCard(
                      name: DateFormat(
                        "hh:mm a",
                      ).format(DateTime(1, 1, 1, dbAlarm.hour, dbAlarm.minute)),
                      color: Colors.green.withOpacity(.5),
                    ),
                  ),
                  Expanded(
                    child: RoundTagCard(
                      name: dbAlarm.repeatType.getUserFriendlyName(context),
                      color: Colors.yellow.withOpacity(.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          value: dbAlarm.isActive,
          onChanged: (value) {
            context.read<AlarmsBloc>().add(
              AlarmsEditEvent(dbAlarm.copyWith(isActive: value)),
            );
          },
        ),
      ],
    );
  }
}
