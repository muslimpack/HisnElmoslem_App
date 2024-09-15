import 'package:get_it/get_it.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';

final sl = GetIt.instance;

Future<void> initSL() async {
  sl.registerLazySingleton(() => TallyDatabaseHelper());
}
