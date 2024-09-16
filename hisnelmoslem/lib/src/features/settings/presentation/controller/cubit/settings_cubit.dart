import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/zikr_effects.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          SettingsState(
            zikrEffects: ZikrEffects(
              soundEffectVolume: AppData.instance.soundEffectVolume,
              isTallySoundAllowed: AppData.instance.isTallySoundAllowed,
              soundEveryPraise: AppData.instance.isZikrDoneSoundAllowed,
              soundEveryZikr: AppData.instance.isTransitionSoundAllowed,
              soundEveryTitle: AppData.instance.isAllAzkarFinishedSoundAllowed,
              isTallyVibrateAllowed: AppData.instance.isTallyVibrateAllowed,
              vibrateEveryPraise: AppData.instance.isZikrDoneVibrateAllowed,
              vibrateEveryZikr: AppData.instance.isTransitionVibrateAllowed,
              vibrateEveryTitle:
                  AppData.instance.isAllAzkarFinishedVibrateAllowed,
            ),
          ),
        );

  ///MARK: Zikr Effects
  Future zikrEffectChangeVolume(double value) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEffectVolume: value),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryPraise({required bool activate}) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEveryPraise: activate),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryZikr({required bool activate}) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEveryZikr: activate),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryTitle({required bool activate}) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEveryTitle: activate),
      ),
    );
  }

  /* Vibration */

  Future zikrEffectChangePlayVibrationEveryPraise({
    required bool activate,
  }) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryPraise: activate),
      ),
    );
  }

  Future zikrEffectChangePlayVibrationEveryZikr({
    required bool activate,
  }) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryZikr: activate),
      ),
    );
  }

  Future zikrEffectChangePlayVibrationEveryTitle({
    required bool activate,
  }) async {
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryTitle: activate),
      ),
    );
  }
}
