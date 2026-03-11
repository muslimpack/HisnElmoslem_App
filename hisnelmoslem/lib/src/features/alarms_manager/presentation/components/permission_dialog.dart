import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';

class PermissionDialog extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const PermissionDialog({
    super.key,
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> with WidgetsBindingObserver {
  bool _notificationsAllowed = false;
  bool _exactAlarmsAllowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = widget.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final nAllowed = await androidPlugin?.areNotificationsEnabled() ?? false;
    final eAllowed = await androidPlugin?.canScheduleExactNotifications() ?? true;

    if (mounted) {
      setState(() {
        _notificationsAllowed = nAllowed;
        _exactAlarmsAllowed = eAllowed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(SX.current.permissionsRequired),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PermissionTile(
              label: SX.current.allowNotifications,
              description: SX.current.notificationPermissionRequired,
              isGranted: _notificationsAllowed,
              onTap: () async {
                if (!_notificationsAllowed) {
                  final androidPlugin = widget.flutterLocalNotificationsPlugin
                      .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin
                      >();
                  await androidPlugin?.requestNotificationsPermission();
                  await _checkPermissions();
                }
              },
            ),
            const SizedBox(height: 16),
            if (Platform.isAndroid)
              _PermissionTile(
                label: SX.current.preciseTiming,
                description: SX.current.preciseTimingDesc,
                isGranted: _exactAlarmsAllowed,
                onTap: () async {
                  if (!_exactAlarmsAllowed) {
                    final androidPlugin = widget.flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                          AndroidFlutterLocalNotificationsPlugin
                        >();
                    await androidPlugin?.requestExactAlarmsPermission();
                    // This often opens settings, so we rely on didChangeAppLifecycleState
                  }
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(SX.current.later),
        ),
        FilledButton(
          onPressed: (_notificationsAllowed && _exactAlarmsAllowed)
              ? () => Navigator.pop(context, true)
              : null,
          child: Text(SX.current.done),
        ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.label,
    required this.description,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isGranted ? Colors.green : theme.dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isGranted ? Colors.green.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isGranted ? Colors.green : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isGranted)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
