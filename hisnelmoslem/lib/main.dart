import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';
import 'package:provider/provider.dart';
import 'Utils/azkar_database_helper.dart';
import 'providers/app_settings.dart';
import 'shared/constant.dart';
import 'utils/notification_manager.dart';
import 'views/screens/dashboard.dart';

void main() async {
  //Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Manage Notification feedback
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //
  String? payload = notificationAppLaunchDetails!.payload;
  debugPrint("main() payload: $payload");
  //
  //U Doesn't open app notification
  localNotifyManager.appOpenNotification();

  // Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: transparent));
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
  void dispose() async {
    //Colse databses
    await azkarDatabaseHelper.close();
    await fakeHadithDatabaseHelper.close();
    await alarmDatabaseHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp payload: ${widget.payload}");
    return ListenableProvider(
      create: (context) => AppSettingsNotifier(),
      child: GetMaterialApp(
        locale: Locale('ar'),
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
