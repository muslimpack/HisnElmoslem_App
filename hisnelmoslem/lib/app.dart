import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/managers/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/core/translations/translation.dart';
import 'package:hisnelmoslem/src/features/alarm/data/data_source/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/dashboard/data/data_source/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/screens/dashboard.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/data_source/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/screens/onboarding.dart';
import 'package:hisnelmoslem/src/features/settings/data/data_source/app_data.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/font_family_page/font_family_page_controller.dart';
import 'package:hisnelmoslem/src/features/tally/data/data_source/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/theme/data/data_source/theme_services.dart';

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
  Future<void> dispose() async {
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
        S.delegate,
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
      home: appData.isFirstOpenToThisRelease
          ? const OnBoardingPage()
          : const AzkarDashboard(),
    );
  }
}
