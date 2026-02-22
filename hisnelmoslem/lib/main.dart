import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/error_screen.dart';
import 'package:hisnelmoslem/init_services.dart';
import 'package:hisnelmoslem/src/features/backup_restore/presentation/components/restart_widget.dart';

void main() async {
  await initServices();
  ErrorWidget.builder = (FlutterErrorDetails details) => ErrorScreen(details: details);
  runApp(
    const RestartWidget(
      child: App(),
    ),
  );
}
