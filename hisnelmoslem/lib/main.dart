import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/views/dashboard/dashboard.dart';
import 'package:hisnelmoslem/views/onboarding/onboarding.dart';
import 'package:intl/intl.dart';
import 'themes/theme_services.dart';
import 'utils/azkar_database_helper.dart';
import 'utils/notification_manager.dart';
import 'utils/tally_database_helper.dart';

void main() async {
  /// Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///
  await GetStorage.init();

  /// Manage Notification feedback
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? payload = notificationAppLaunchDetails!.payload;
  DashboardController dashboardController = Get.put(DashboardController());
  dashboardController.payload = payload;

  /// U Doesn't open app for long time notification
  await localNotifyManager.appOpenNotification();

  /// Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  /// Keep app in portrait mode and
  /// make it static when phone rotation change
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ///
  Intl.defaultLocale = 'ar';

  ///
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
    await tallyDatabaseHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO to be deleted in next update
    final box = GetStorage();
    final openOnBoard = box.read('is_v2.0_first_open') ?? true;
    return GetMaterialApp(
      locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      title: 'حصن المسلم',
      theme: ThemeServices.getTheme(),
      // theme: Themes.yellowTheme,
      // home: const AzkarDashboard(),
      // TODO to be deleted in next update
      home: openOnBoard ? const OnBoardingPage() : const AzkarDashboard(),
    );
  }
}
