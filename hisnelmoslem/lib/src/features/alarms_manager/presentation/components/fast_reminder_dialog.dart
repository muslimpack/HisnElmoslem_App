import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';

/// Lets the user choose when the Monday/Thursday fasting reminders arrive.
class FastReminderDialog extends StatelessWidget {
  const FastReminderDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AlarmsBloc>(),
        child: const FastReminderDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        if (state is! AlarmsLoadedState) return const SizedBox.shrink();
        final time = TimeOfDay(hour: state.fastHour, minute: state.fastMinute);

        return AlertDialog(
          title: Text(s.fastingMondaysThursdaysReminder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(s.fastingReminderTime),
                trailing: Text(
                  time.format(context),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: time);
                  if (picked == null || !context.mounted) return;
                  context.read<AlarmsBloc>().add(
                    AlarmsFastScheduleChangedEvent(
                      hour: picked.hour,
                      minute: picked.minute,
                      sameDay: state.fastSameDay,
                    ),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.fastingRemindSameDay),
                subtitle: Text(s.fastingRemindSameDayDesc),
                value: state.fastSameDay,
                onChanged: (value) {
                  context.read<AlarmsBloc>().add(
                    AlarmsFastScheduleChangedEvent(
                      hour: state.fastHour,
                      minute: state.fastMinute,
                      sameDay: value,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.done),
            ),
          ],
        );
      },
    );
  }
}
