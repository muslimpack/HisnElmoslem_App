import 'package:hisnelmoslem/Screen/splash_screen.dart';
import 'package:hisnelmoslem/provider/azkar_mode.dart';
import 'package:hisnelmoslem/provider/fontsize.dart';
import 'package:hisnelmoslem/provider/settings_provider.dart';
import 'package:hisnelmoslem/provider/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(ThemeData.dark())),
        ChangeNotifierProvider<FontSizeNotifier>(
            create: (_) => FontSizeNotifier()),
        ChangeNotifierProvider<UserSettingsNotifier>(
            create: (_) => UserSettingsNotifier()),
        ChangeNotifierProvider<AzkarMode>(create: (_) => AzkarMode())
      ],
      child: MaterialAppWithProvider(),
    );
  }
}

class MaterialAppWithProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حصن المسلم',
      theme: theme.getTheme(),
      home: SplashScreen(),
    );
  }
}
