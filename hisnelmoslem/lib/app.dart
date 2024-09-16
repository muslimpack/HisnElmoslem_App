import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/scroll_behavior.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/localization/translation.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/repository/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/home_screen.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/screens/onboarding.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/ui/presentation/components/desktop_window_wrapper.dart';

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    awesomeNotificationManager.listen();
  }

  @override
  Future<void> dispose() async {
    await sl<AzkarDatabaseHelper>().close();
    await sl<FakeHadithDBHelper>().close();
    await sl<AlarmDatabaseHelper>().close();
    await sl<TallyDatabaseHelper>().close();
    awesomeNotificationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(
          create: (_) => sl<AlarmsBloc>()..add(AlarmsStartEvent()),
        ),
        BlocProvider(
          create: (_) => sl<HomeBloc>()..add(HomeStartEvent()),
        ),
        BlocProvider(
          create: (_) => sl<SearchCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return GetMaterialApp(
            navigatorKey: App.navigatorKey,
            scrollBehavior: AppScrollBehavior(),
            // Translation
            translations: HisnAppTranslation(),
            locale: state.locale,
            fallbackLocale: const Locale("ar"),
            supportedLocales: const [Locale("ar"), Locale("en")],
            //
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: "Hisn Elmoslem".tr,
            theme: state.themeData(),
            navigatorObservers: [
              BotToastNavigatorObserver(),
            ],
            builder: (context, child) {
              if (PlatformExtension.isDesktop) {
                final botToastBuilder = BotToastInit();
                return DesktopWindowWrapper(
                  child: botToastBuilder(context, child),
                );
              }
              return child ?? const SizedBox();
            },

            // home: const AzkarDashboard(),

            home: sl<AppSettingsRepo>().isReleaseFirstOpen
                ? const OnBoardingPage()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
