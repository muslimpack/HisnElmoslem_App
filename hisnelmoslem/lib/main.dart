import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/error_screen.dart';
import 'package:hisnelmoslem/init_services.dart';

void main() async {
  await initServices();
  ErrorWidget.builder = (FlutterErrorDetails details) =>
      ErrorScreen(details: details);
  runApp(const App());
}
