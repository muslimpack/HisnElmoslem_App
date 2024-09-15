import 'package:get_it/get_it.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/quran/data/repository/uthmani_repository.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';

final sl = GetIt.instance;

Future<void> initSL() async {
  sl.registerLazySingleton(() => TallyDatabaseHelper());
  sl.registerLazySingleton(() => AlarmDatabaseHelper());
  sl.registerLazySingleton(() => UthmaniRepository());
}
