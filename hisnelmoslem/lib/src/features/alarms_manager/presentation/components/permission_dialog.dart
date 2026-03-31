import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final nAllowed = await sl<LocalNotificationManager>().isPermissionGranted();
    bool eAllowed = true;

    if (Platform.isAndroid) {
      final androidPlugin = widget.flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      eAllowed = await androidPlugin?.canScheduleExactNotifications() ?? true;
    }

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
                  if (Platform.isAndroid) {
                    final androidPlugin = widget.flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                          AndroidFlutterLocalNotificationsPlugin
                        >();
                    await androidPlugin?.requestNotificationsPermission();
                  } else if (Platform.isIOS) {
                    final iosPlugin = widget.flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                          IOSFlutterLocalNotificationsPlugin
                        >();
                    final bool? granted = await iosPlugin?.requestPermissions(
                      alert: true,
                      badge: true,
                      sound: true,
                    );

                    if (granted == false) {
                      // On iOS, if permission was already denied, the system dialog won't show.
                      // We should offer to open settings.
                      if (context.mounted) {
                        await launchUrl(Uri.parse('app-settings:'));
                      }
                    }
                  }
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
          onPressed: () {
            sl<AppSettingsRepo>().changeIgnoreNotificationPermissionStatus(
              value: true,
            );
            Navigator.pop(context, false);
          },
          child: Text(SX.current.ignoreNotificationPermission),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(SX.current.later),
        ),
        FilledButton(
          onPressed: (_notificationsAllowed && (!Platform.isAndroid || _exactAlarmsAllowed))
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
