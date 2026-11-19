import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart' as service_locator;
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/utils/app_bloc_observer.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_repo.dart';
import 'package:hisnelmoslem/src/features/ui/data/repository/local_repo.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart' as sqlite;
import 'package:window_manager/window_manager.dart';

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  _setUpErrorCapture();

  if (PlatformExtension.isLinux) {
    PathProviderPlatform.instance = _LinuxAppPathProvider();
    await GetStorage.init(kAppStorageKey);
  }

  service_locator.initSL();

  await loadLocalizations();

  await phoneDeviceBars();

  if (PlatformExtension.isDesktopOrWeb) {
    sqfliteFfiInit();
    databaseFactory = PlatformExtension.isLinux
        ? createDatabaseFactoryFfi(ffiInit: _loadLinuxSqlite)
        : databaseFactoryFfi;
    if (PlatformExtension.isLinux) {
      // The FFI default is relative to the working directory, which can be read-only.
      final directory = await getApplicationSupportDirectory();
      await databaseFactory.setDatabasesPath(directory.path);
    }
  }

  try {
    await GetStorage.init(kAppStorageKey);
    // Not awaited: it needs a few platform calls and the time zone database, and nothing
    // before the first frame depends on it. Users of the manager wait on `ensureReady`.
    if (PlatformExtension.supportsScheduledReminders) {
      unawaited(sl<LocalNotificationManager>().init());
    }
    // A download that was running when the app closed is shown as paused, ready to resume.
    sl<ReciterDownloadsCubit>().restore();
  } catch (e) {
    hisnPrint(e);
  }

  await initWindowsManager();
}

void _loadLinuxSqlite() {
  // Use the runtime library name so users don't need the development package.
  sqlite.open.overrideFor(
    sqlite.OperatingSystem.linux,
    () => DynamicLibrary.open('libsqlite3.so.0'),
  );
}

class _LinuxAppPathProvider extends PathProviderLinux {
  // Settings and recordings need app-private storage even without an XDG Documents directory.
  @override
  Future<String?> getApplicationDocumentsPath() => getApplicationSupportPath();
}

/// Sends every uncaught error (framework, async and platform) to the local error log, which a
/// bug report can attach. Nothing is uploaded.
void _setUpErrorCapture() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    hisnLogError(details.exception, details.stack, source: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    hisnLogError(error, stack, source: 'platform');
    return true;
  };
}

Future phoneDeviceBars() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future initWindowsManager() async {
  if (!PlatformExtension.isDesktop) return;

  await windowManager.ensureInitialized();

  final WindowOptions windowOptions = WindowOptions(
    size: sl<UIRepo>().desktopWindowSize,
    center: true,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.show();
    await windowManager.focus();
  });
}

Future loadLocalizations() async {
  final localeToSet = sl<ThemeRepo>().appLocale;
  Intl.defaultLocale = localeToSet.languageCode;
  final s = await S.delegate.load(localeToSet);
  SX.init(s);
}
