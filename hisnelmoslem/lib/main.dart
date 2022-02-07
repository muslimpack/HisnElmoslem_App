import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';
import 'package:provider/provider.dart';
import 'Utils/azkar_database_helper.dart';
import 'providers/app_settings.dart';
import 'shared/constants/constant.dart';
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
  DashboardController dashboardController = Get.put(DashboardController());
  dashboardController.payload = payload;
  //
  //U Doesn't open app notification
  await localNotifyManager.appOpenNotification();

  // Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: transparent));
  //
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);


  runApp(MyApp(
  ));
}

class MyApp extends StatefulWidget {
  MyApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() async {
    //Close databases
    await azkarDatabaseHelper.close();
    await fakeHadithDatabaseHelper.close();
    await alarmDatabaseHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ListenableProvider(
      create: (context) => AppSettingsNotifier(),
      child: GetMaterialApp(
        locale: Locale('ar'),
        debugShowCheckedModeBanner: false,
        title: 'حصن المسلم',
        theme: ThemeData.dark(),
        home: AzkarDashboard(),
      ),
    );
  }
}
