import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/app/app.dart';
import 'package:hisnelmoslem/app/init_services.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Intl.defaultLocale = 'ar';
  runApp(const MyApp());
}