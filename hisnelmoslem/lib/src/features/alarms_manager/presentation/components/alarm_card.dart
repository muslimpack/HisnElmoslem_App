import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/alarm_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
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
              final alarm = await showAlarmEditorDialog(
                context: context,
                dbAlarm: dbAlarm,
                isToEdit: true,
              );

              if (alarm is! DbAlarm) return;
              if (!alarm.hasAlarmInside) return;
              if (!context.mounted) return;

              sl<AlarmsBloc>().add(AlarmsEditEvent(alarm));
            },
            icon: Icons.edit,
            label: 'edit'.tr,
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: .3,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (val) async {
              sl<AlarmsBloc>().add(AlarmsRemoveEvent(dbAlarm));
            },
            backgroundColor: Colors.red.withOpacity(.5),
            icon: Icons.delete,
            label: "delete".tr,
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
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alarm),
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
                        name: DateFormat("hh:mm a").format(
                          DateTime(1, 1, 1, dbAlarm.hour, dbAlarm.minute),
                        ),
                        color: Colors.green.withOpacity(.5),
                      ),
                    ),
                    Expanded(
                      child: RoundTagCard(
                        name: dbAlarm.repeatType.getUserFriendlyName(),
                        color: Colors.yellow.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            title: Text(dbAlarm.title),
          ),
          value: dbAlarm.isActive,
          onChanged: (value) {
            sl<AlarmsBloc>().add(
              AlarmsEditEvent(
                dbAlarm.copyWith(isActive: value),
              ),
            );
          },
        ),
      ],
    );
  }
}
