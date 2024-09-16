// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/zikr_effects.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';

part 'settings_state.dart';

///TODO save effect manager changes
class SettingsCubit extends Cubit<SettingsState> {
  final EffectsManagerRepo effectsManagerRepo;
  final AppSettingsRepo appSettingsRepo;
  SettingsCubit(
    this.effectsManagerRepo,
    this.appSettingsRepo,
  ) : super(
          SettingsState(
            zikrEffects: ZikrEffects(
              soundEffectVolume: effectsManagerRepo.soundEffectVolume,
              isTallySoundAllowed: effectsManagerRepo.isTallySoundAllowed,
              soundEveryPraise: effectsManagerRepo.isZikrDoneSoundAllowed,
              soundEveryZikr: effectsManagerRepo.isTransitionSoundAllowed,
              soundEveryTitle:
                  effectsManagerRepo.isAllAzkarFinishedSoundAllowed,
              isTallyVibrateAllowed: effectsManagerRepo.isTallyVibrateAllowed,
              vibrateEveryPraise: effectsManagerRepo.isZikrDoneVibrateAllowed,
              vibrateEveryZikr: effectsManagerRepo.isTransitionVibrateAllowed,
              vibrateEveryTitle:
                  effectsManagerRepo.isAllAzkarFinishedVibrateAllowed,
            ),
            enableWakeLock: appSettingsRepo.enableWakeLock,
            isCardReadMode: appSettingsRepo.isCardReadMode,
            useHindiDigits: appSettingsRepo.useHindiDigits,
          ),
        );

  ///MARK: General Settings
  Future toggleIsCardReadMode({required bool activate}) async {
    await appSettingsRepo.changeReadModeStatus(value: activate);
    emit(state.copyWith(isCardReadMode: activate));
  }

  Future toggleUseHiniDigits({required bool use}) async {
    await appSettingsRepo.changeUseHindiDigits(use: use);
    emit(state.copyWith(useHindiDigits: use));
  }

  Future toggleWakeLock({required bool use}) async {
    await appSettingsRepo.changeEnableWakeLock(use: use);
    emit(state.copyWith(enableWakeLock: use));
  }

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
