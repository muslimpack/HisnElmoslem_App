import 'package:flutter/material.dart';

/// Icon above a short label; one cell of the zikr actions sheet.
class ZikrActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Accent for the icon background (defaults to the theme primary).
  final Color? color;

  const ZikrActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: accent.withAlpha(30),
              foregroundColor: accent,
              child: Icon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
