import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarms_repo.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/azakr_filters_repo.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/presentation/controller/cubit/azkar_filters_cubit.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/repository/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/bloc/fake_hadith_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/commentary_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/data_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/controller/cubit/onboard_cubit.dart';
import 'package:hisnelmoslem/src/features/quran/data/repository/uthmani_repository.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/controller/cubit/quran_cubit.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/zikr_text_repo.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_repo.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/ui/data/repository/local_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/repository/zikr_viewer_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

final sl = GetIt.instance;

Future<void> initSL() async {
  ///MARK: Init storages
  sl.registerLazySingleton(() => GetStorage(kAppStorageKey));
  sl.registerLazySingleton(() => UIRepo(sl()));
  sl.registerLazySingleton(() => ThemeRepo(sl()));
  sl.registerLazySingleton(() => EffectsManagerRepo(sl()));
  sl.registerLazySingleton(() => ShareAsImageRepo(sl()));
  sl.registerLazySingleton(() => AppSettingsRepo(sl()));
  sl.registerLazySingleton(() => AlarmsRepo(sl()));
  sl.registerLazySingleton(() => ZikrTextRepo(sl()));
  sl.registerLazySingleton(() => ZikrViewerRepo(sl()));
  sl.registerLazySingleton(() => AzkarFiltersRepo(sl()));

  ///MARK: Init Repo
  sl.registerLazySingleton(() => TallyDatabaseHelper());
  sl.registerLazySingleton(() => AlarmDatabaseHelper());
  sl.registerLazySingleton(() => UthmaniRepository());
  sl.registerLazySingleton(() => UserDataDBHelper());
  sl.registerLazySingleton(() => HisnDBHelper(sl()));
  sl.registerLazySingleton(() => FakeHadithDBHelper(sl()));
  sl.registerLazySingleton(() => CommentaryDBHelper());

  ///MARK: Init Manager
  sl.registerFactory(() => EffectsManager(sl()));
  sl.registerFactory(() => AwesomeNotificationManager());
  sl.registerFactory(() => AlarmManager(sl()));
  sl.registerFactory(() => VolumeButtonManager());

  ///MARK: Init BLOC

  /// Singleton BLoC
  sl.registerLazySingleton(() => ThemeCubit(sl()));
  sl.registerLazySingleton(() => AlarmsBloc(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => HomeBloc(sl(), sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => SearchCubit(sl()));
  sl.registerLazySingleton(() => SettingsCubit(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => AzkarFiltersCubit(sl()));

  /// Factory BLoC
  sl.registerFactory(() => OnboardCubit(sl(), sl()));
  sl.registerFactory(() => TallyBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ShareImageCubit(sl()));
  sl.registerFactory(() => QuranCubit());
  sl.registerFactory(() => FakeHadithBloc(sl()));
  sl.registerFactory(() => ZikrViewerBloc(sl(), sl(), sl(), sl(), sl(), sl()));
}
