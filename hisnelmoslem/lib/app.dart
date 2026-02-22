import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/scroll_behavior.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/presentation/controller/cubit/azkar_filters_cubit.dart';
import 'package:hisnelmoslem/src/features/backup_restore/presentation/controller/cubit/backup_restore_cubit.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/home_screen.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/ui/presentation/components/desktop_window_wrapper.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await sl<LocalNotificationManager>().requestPermissionWithDialog();
        sl<LocalNotificationManager>().handleLaunchNotification();
      } catch (e) {
        hisnPrint(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<AzkarFiltersCubit>()),
        BlocProvider(create: (_) => sl<AlarmsBloc>()..add(AlarmsStartEvent())),
        BlocProvider(
          create: (_) => sl<BookmarkBloc>()..add(BookmarkStartEvent()),
        ),
        BlocProvider(create: (_) => sl<HomeBloc>()..add(HomeStartEvent())),
        BlocProvider(create: (context) => sl<SearchCubit>()..start()),
        BlocProvider(create: (_) => sl<ZikrAudioPlayerCubit>()),
        BlocProvider(create: (_) => sl<BackupRestoreCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: App.navigatorKey,
            onGenerateTitle: (context) => S.of(context).hisnElmoslem,
            scrollBehavior: AppScrollBehavior(),
            locale: state.locale,
            supportedLocales: S.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              return locale != null && supportedLocales.contains(locale)
                  ? locale
                  : supportedLocales.first;
            },
            debugShowCheckedModeBanner: false,
            theme: state.theme,
            navigatorObservers: [BotToastNavigatorObserver()],
            builder: (context, child) {
              if (PlatformExtension.isDesktop) {
                final botToastBuilder = BotToastInit();
                return DesktopWindowWrapper(
                  child: botToastBuilder(context, child),
                );
              }
              return child ?? const SizedBox();
            },
            home: sl<AppSettingsRepo>().currentVersion != sl<PackageInfo>().version
                ? const OnBoardingScreen()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
