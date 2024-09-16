// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/zikr_effects.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final EffectsManager effectsManager;
  final EffectsManagerRepo effectsManagerRepo;
  final AppSettingsRepo appSettingsRepo;
  SettingsCubit(
    this.effectsManagerRepo,
    this.appSettingsRepo,
    this.effectsManager,
  ) : super(
          SettingsState(
            zikrEffects: ZikrEffects(
              soundEffectVolume: effectsManagerRepo.soundEffectVolume,
              soundEveryPraise: effectsManagerRepo.isPraiseSoundAllowed,
              soundEveryZikr: effectsManagerRepo.isZikrSoundAllowed,
              soundEveryTitle: effectsManagerRepo.isTitleSoundAllowed,
              vibrateEveryPraise: effectsManagerRepo.isPraiseVibrationAllowed,
              vibrateEveryZikr: effectsManagerRepo.isZikrVibrationAllowed,
              vibrateEveryTitle: effectsManagerRepo.isTitleVibrationAllowed,
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
    await effectsManagerRepo.changeSoundEffectVolume(value);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEffectVolume: value),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryPraise({required bool activate}) async {
    if (activate) {
      await effectsManager.playPraiseSound();
    }
    await effectsManagerRepo.changePraiseSoundStatus(value: activate);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEveryPraise: activate),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryZikr({required bool activate}) async {
    if (activate) {
      await effectsManager.playZikrSound();
    }
    await effectsManagerRepo.changeZikrSoundStatus(value: activate);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(soundEveryZikr: activate),
      ),
    );
  }

  Future zikrEffectChangePlaySoundEveryTitle({required bool activate}) async {
    if (activate) {
      await effectsManager.playTitleSound();
    }
    await effectsManagerRepo.changeTitleSoundStatus(value: activate);
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
    if (activate) {
      await effectsManager.playPraiseVibratation();
    }
    await effectsManagerRepo.changePraiseVibrationStatus(value: activate);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryPraise: activate),
      ),
    );
  }

  Future zikrEffectChangePlayVibrationEveryZikr({
    required bool activate,
  }) async {
    if (activate) {
      await effectsManager.playZikrVibratation();
    }
    await effectsManagerRepo.changeZikrVibrationStatus(value: activate);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryZikr: activate),
      ),
    );
  }

  Future zikrEffectChangePlayVibrationEveryTitle({
    required bool activate,
  }) async {
    if (activate) {
      await effectsManager.playTitleVibratation();
    }
    await effectsManagerRepo.changeTitleVibrationStatus(value: activate);
    emit(
      state.copyWith(
        zikrEffects: state.zikrEffects.copyWith(vibrateEveryTitle: activate),
      ),
    );
  }
}
