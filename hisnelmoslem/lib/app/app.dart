import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/modules/font_family_page/font_family_page_controller.dart';
import 'package:hisnelmoslem/app/modules/onboarding/onboarding.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard.dart';
import 'package:hisnelmoslem/core/themes/theme_services.dart';
import 'package:hisnelmoslem/core/themes/themes.dart';
import 'package:hisnelmoslem/core/translations/translation.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/core/utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/core/utils/tally_database_helper.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        textTheme: ThemeServices.getTheme()
            .textTheme
            .apply(fontFamily: appData.fontFamily),
        primaryTextTheme: ThemeServices.getTheme()
            .textTheme
            .apply(fontFamily: appData.fontFamily),
      ),
      // theme: Themes.yellowTheme,
      // home: const AzkarDashboard(),
      home: (appData.isFirstOpenToThisRelease
          ? const OnBoardingPage()
          : const AzkarDashboard()),
    );
  }
}
