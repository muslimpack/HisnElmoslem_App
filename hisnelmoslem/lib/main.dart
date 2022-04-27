import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/themes/theme_services.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/views/screens/dashboard.dart';
import 'utils/azkar_database_helper.dart';
import 'utils/notification_manager.dart';

void main() async {
  /// Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///
  await GetStorage.init();

  /// If user have old version of hisnElmoslem consider
  /// to disable all notification as all alrams and
  /// bookmared titles will be deleted in V1.5
  // final box = GetStorage();
  // if (box.read('is_v1.5_first_open') ?? true) {
  // //   await localNotifyManager.cancelAllNotifications();
  // }

  /// Manage Notification feedback
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? payload = notificationAppLaunchDetails!.payload;
  debugPrint("main() payload: $payload");
  DashboardController dashboardController = Get.put(DashboardController());
  dashboardController.payload = payload;

  /// U Doesn't open app for long time notification
  await localNotifyManager.appOpenNotification();

  /// Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
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
    /// Keep app in portrait mode and
    /// make it static when phone rotation change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      title: 'حصن المسلم',
      theme: ThemeServices.getTheme(),
      home: const AzkarDashboard(),
    );
  }
}
