import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';

class TallyRepo {
  final GetStorage box;
  TallyRepo(this.box);

  static const String iterationModeKey = 'tallyIterationMode';

  TallyIterationMode get getIterationMode =>
      TallyIterationMode.values
          .where((x) => x.name == box.read(iterationModeKey))
          .firstOrNull ??
      TallyIterationMode.none;

  Future saveIterationMode(TallyIterationMode iterationMode) async =>
      box.write(iterationModeKey, iterationMode.name);
}
