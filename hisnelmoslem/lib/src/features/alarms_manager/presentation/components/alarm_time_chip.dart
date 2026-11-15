import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

/// Shows a title's reminder time next to its bell so the reminder is visible,
/// and opens the editor when tapped (instead of relying on a hidden long press).
class AlarmTimeChip extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isActive;
  final VoidCallback onTap;

  const AlarmTimeChip({
    super.key,
    required this.hour,
    required this.minute,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = TimeOfDay(hour: hour, minute: minute).format(context);

    return Tooltip(
      message: S.of(context).editReminder,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            time,
            textDirection: TextDirection.ltr,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isActive ? theme.colorScheme.primary : theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
