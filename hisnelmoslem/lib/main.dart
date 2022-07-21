import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/core/utils/migration/migration.dart';
import 'package:hisnelmoslem/core/utils/notification_manager.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard.dart';
import 'package:hisnelmoslem/app/modules/onboarding/onboarding.dart';
import 'package:intl/intl.dart';

import 'core/themes/theme_services.dart';
import 'core/utils/azkar_database_helper.dart';
import 'core/utils/tally_database_helper.dart';

void main() async {
  /// Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///
  await GetStorage.init();

  /// Start Migration steps
  await Migration.start();

  /// Init Awesome Notification
  await awesomeNotificationManager.init();

  /// Disable all notification from local_notification
  await localNotifyManager.cancelAllNotifications();

  /// U Doesn't open app for long time notification
  await awesomeNotificationManager.appOpenNotification();
  await alarmManager.checkAllAlarmsInDb();

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
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    awesomeNotificationManager.listen();
  }

  @override
  void dispose() async {
    //Close databases
    await azkarDatabaseHelper.close();
    await fakeHadithDatabaseHelper.close();
    await alarmDatabaseHelper.close();
    await tallyDatabaseHelper.close();
    awesomeNotificationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'حصن المسلم',
      theme: ThemeServices.getTheme(),
      // theme: Themes.yellowTheme,
      // home: const AzkarDashboard(),
      home: appData.isFirstOpenToThisRelease
          ? const OnBoardingPage()
          : const AzkarDashboard(),
    );
  }
}
