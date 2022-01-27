import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Utils/alarm_database_helper.dart';
import 'package:provider/provider.dart';
import 'AppManager/NotificationManager.dart';
import 'Screens/Dashboard.dart';
import 'Utils/azkar_database_helper.dart';

void main() async {
  //Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Manage Notification feedback
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? payload = notificationAppLaunchDetails!.payload;
  debugPrint("main() payload: $payload");
  //
  //U Doesn't open app notification
  localNotifyManager.appOpenNotification();

  //Initialize Databases
  await azkarDatabaseHelper.initDb();
  await alarmDatabaseHelper.initDb();

  //Set All Alarm in database to confirm it
  // await alarmManager.checkAllAlarms();

  // Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  //
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  runApp(MyApp(
    payload: payload ?? "",
  ));
}

class MyApp extends StatefulWidget {
  final String? payload;
  MyApp({required this.payload});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp payload: ${widget.payload}");
    return ListenableProvider(
      create: (context) => AppSettingsNotifier(),
      child: MaterialApp(
        // Make UI RTL
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('ar', 'AE')],
        debugShowCheckedModeBanner: false,
        title: 'حصن المسلم',
        theme: ThemeData.dark(),
        home: AzkarDashboard(
          payload: widget.payload,
        ),
      ),
    );
  }
}
