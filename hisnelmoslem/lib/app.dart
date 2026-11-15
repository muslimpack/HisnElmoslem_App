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
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/home_screen.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_activity_pill.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/screens/download_center_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';
import 'package:hisnelmoslem/src/features/ui/presentation/components/desktop_window_wrapper.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _replanAlarmsIfTimeZoneChanged();
  }

  /// A DST change or a trip to another time zone while the app was in the
  /// background leaves alarms an hour (or more) off, so plan them again.
  Future<void> _replanAlarmsIfTimeZoneChanged() async {
    try {
      if (!await sl<LocalNotificationManager>().refreshTimeZone()) return;
      final context = App.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      context.read<AlarmsBloc>().add(AlarmsStartEvent());
    } catch (e) {
      hisnPrint(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final notifications = sl<LocalNotificationManager>();
        notifications.handleLaunchNotification();
        // Ask once the user has alarms but the system blocks them.
        await notifications.requestPermissionWithDialog(triggerOnStartup: true);
        if (await notifications.isPermissionGranted()) {
          await notifications.appOpenNotification();
        }
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
        BlocProvider(create: (_) => sl<TranslationsCubit>()..start()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<AzkarFiltersCubit>()),
        BlocProvider(create: (_) => sl<AlarmsBloc>()..add(AlarmsStartEvent())),
        BlocProvider(
          create: (_) => sl<BookmarkBloc>()..add(BookmarkStartEvent()),
        ),
        BlocProvider(
          create: (_) => sl<CustomTitlesBloc>()..add(const CustomTitlesStartEvent()),
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
              if (locale == null) return supportedLocales.first;
              // A device locale with a region (fr_FR) still matches its language.
              return supportedLocales.firstWhere(
                (supported) => supported.languageCode == locale.languageCode,
                orElse: () => supportedLocales.first,
              );
            },
            debugShowCheckedModeBanner: false,
            theme: state.theme,
            navigatorObservers: [BotToastNavigatorObserver()],
            builder: (context, child) {
              // Above every screen: the small pill that shows a download in the background.
              final app = Stack(
                children: [
                  child ?? const SizedBox(),
                  DownloadActivityPill(
                    downloads: sl<ReciterDownloadsCubit>(),
                    onTap: () => App.navigatorKey.currentState?.push(
                      MaterialPageRoute<void>(builder: (_) => const DownloadCenterScreen()),
                    ),
                  ),
                ],
              );
              if (PlatformExtension.isDesktop) {
                final botToastBuilder = BotToastInit();
                return DesktopWindowWrapper(
                  child: botToastBuilder(context, app),
                );
              }
              return app;
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
