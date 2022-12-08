import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/modules/font_family_page/font_family_page_controller.dart';
import 'package:hisnelmoslem/core/translations/translation.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/core/utils/migration/migration.dart';
import 'package:hisnelmoslem/core/utils/notification_manager.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard.dart';
import 'package:hisnelmoslem/app/modules/onboarding/onboarding.dart';

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

  /// Keep app in portrait mode and
  /// make it static when phone rotation change
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ///
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  FontFamilyPageController familyPageController =
      Get.put(FontFamilyPageController());
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
        // Translation
        translations: HisnAppTranslation(),
        locale: Locale(appData.appLocale),
        fallbackLocale: Locale(appData.appLocale),
        //
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: "Hisn Elmoslem".tr,
        theme: ThemeServices.getTheme().copyWith(
          textTheme: ThemeServices.getTheme().textTheme.apply(
                fontFamily: appData.fontFamily,
              ),
          primaryTextTheme: ThemeServices.getTheme().textTheme.apply(
                fontFamily: appData.fontFamily,
              ),
        ),
        // theme: Themes.yellowTheme,
        // home: const AzkarDashboard(),
        home: (appData.isFirstOpenToThisRelease
            ? const OnBoardingPage()
            : const AzkarDashboard()));
  }
}
