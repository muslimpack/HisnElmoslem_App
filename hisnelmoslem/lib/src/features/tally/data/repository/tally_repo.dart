import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_advance_trigger.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';

class TallyRepo {
  final GetStorage box;
  TallyRepo(this.box);

  static const String iterationModeKey = 'tallyIterationMode';
  static const String advanceTriggerKey = 'tallyAdvanceTrigger';
  static const String sessionLimitTypeKey = 'tallySessionLimitType';
  static const String sessionLimitValueKey = 'tallySessionLimitValue';

  /// When auto-advance moves to the next counter: after every count or every cycle.
  TallyAdvanceTrigger get getAdvanceTrigger =>
      TallyAdvanceTrigger.fromName(box.read<String>(advanceTriggerKey));

  Future saveAdvanceTrigger(TallyAdvanceTrigger trigger) =>
      box.write(advanceTriggerKey, trigger.name);

  TallyIterationMode get getIterationMode =>
      TallyIterationMode.values.where((x) => x.name == box.read(iterationModeKey)).firstOrNull ??
      TallyIterationMode.none;

  Future saveIterationMode(TallyIterationMode iterationMode) =>
      box.write(iterationModeKey, iterationMode.name);

  /// When a voice playback session stops by itself (never, after minutes, after counts).
  TallySessionLimit get getSessionLimit => TallySessionLimit.fromStorage(
    box.read<String>(sessionLimitTypeKey),
    box.read<int>(sessionLimitValueKey),
  );

  Future<void> saveSessionLimit(TallySessionLimit limit) async {
    await box.write(sessionLimitTypeKey, limit.type.name);
    await box.write(sessionLimitValueKey, limit.value);
  }
}
