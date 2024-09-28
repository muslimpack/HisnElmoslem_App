// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/zikr_effects.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/repository/effects_manager_repo.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/zikr_text_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/repository/zikr_viewer_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final EffectsManager effectsManager;
  final EffectsManagerRepo effectsManagerRepo;
  final AppSettingsRepo appSettingsRepo;
  final ZikrTextRepo zikrTextRepo;
  final ZikrViewerRepo zikrViewerRepo;
  SettingsCubit(
    this.effectsManagerRepo,
    this.appSettingsRepo,
    this.effectsManager,
    this.zikrTextRepo,
    this.zikrViewerRepo,
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
            fontSize: zikrTextRepo.fontSize,
            showDiacritics: zikrTextRepo.showDiacritics,
            praiseWithVolumeKeys: appSettingsRepo.praiseWithVolumeKeys,
            allowZikrSessionRestoration:
                zikrViewerRepo.allowZikrSessionRestoration,
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

  Future toggleAllowZikrSessionRestoration({required bool allow}) async {
    await zikrViewerRepo.toggleAllowZikrSessionRestoration(allow);
    emit(state.copyWith(allowZikrSessionRestoration: allow));
  }

  ///MARK: praiseWithVolumeKeys
  Future togglePraiseWithVolumeKeys({required bool use}) async {
    await appSettingsRepo.changePraiseWithVolumeKeysStatus(value: use);
    emit(state.copyWith(praiseWithVolumeKeys: use));
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
      effectsManager.playPraiseSound();
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
      effectsManager.playZikrSound();
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
      effectsManager.playTitleSound();
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

  ///MARK: Zikr Text

  Future<void> changFontSize(double value) async {
    final double tempValue = value.clamp(kFontMin, kFontMax);
    await zikrTextRepo.changFontSize(tempValue);
    emit(state.copyWith(fontSize: tempValue));
  }

  Future resetFontSize() async {
    await changFontSize(kFontDefault);
  }

  Future increaseFontSize() async {
    await changFontSize(state.fontSize + kFontChangeBy);
  }

  Future decreaseFontSize() async {
    await changFontSize(state.fontSize - kFontChangeBy);
  }

  /* ******* Diacritics ******* */

  Future<void> changDiacriticsStatus({required bool value}) async {
    await zikrTextRepo.changDiacriticsStatus(value: value);
    emit(state.copyWith(showDiacritics: value));
  }

  Future<void> toggleDiacriticsStatus() async {
    await changDiacriticsStatus(value: !state.showDiacritics);
  }
}
