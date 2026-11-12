import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_name.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/screens/download_center_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';

/// Playback speed, volume and the pause between azkar, as one card per setting.
class ZikrAudioSettingsDialog extends StatelessWidget {
  /// Adds the entry that opens the reciter and downloads sheet. Off in tests, which have no
  /// service locator.
  final bool showReciterEntry;

  const ZikrAudioSettingsDialog({super.key, this.showReciterEntry = false});

  /// Bottom sheet with the settings of the zikr audio.
  ///
  /// The sheet is a separate route and does not see the viewer's providers, so the
  /// cubit is taken from [context] or given as [cubit].
  static Future<void> show(BuildContext context, {ZikrAudioPlayerCubit? cubit}) {
    final audioCubit = cubit ?? context.read<ZikrAudioPlayerCubit>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: audioCubit,
        child: const SafeArea(top: false, child: ZikrAudioSettingsDialog(showReciterEntry: true)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).audioPlayerSettings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const AudioSpeedSetting(),
          const SizedBox(height: 12),
          const AudioVolumeSetting(),
          const SizedBox(height: 12),
          const AudioDelaySetting(),
          if (showReciterEntry) ...[
            const SizedBox(height: 12),
            const ReciterEntryCard(),
          ],
        ],
      ),
    );
  }
}

/// Frame of one setting: icon, title, current value and the control underneath.
class AudioSettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget child;

  const AudioSettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withAlpha(30),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class AudioSpeedSetting extends StatelessWidget {
  const AudioSpeedSetting({super.key});

  static const _presets = [0.75, 1.0, 1.25, 1.5, 2.0];

  /// `1`, `0.75`, `1.5`: no trailing zeros.
  static String format(double speed) {
    final text = speed.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ZikrAudioPlayerCubit>();

    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      buildWhen: (a, b) => a.playbackSpeed != b.playbackSpeed,
      builder: (context, state) {
        return AudioSettingCard(
          icon: Icons.speed_rounded,
          title: S.of(context).audioPlayerSpeed,
          value: "${format(state.playbackSpeed)}×",
          child: Column(
            children: [
              Slider(
                value: state.playbackSpeed.clamp(0.5, 2.0),
                min: 0.5,
                max: 2.0,
                divisions: 30,
                onChanged: (value) => cubit.saveSettings(speed: value),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final speed in _presets)
                    ChoiceChip(
                      label: Text("${format(speed)}×"),
                      selected: (state.playbackSpeed - speed).abs() < 0.01,
                      onSelected: (_) => cubit.saveSettings(speed: speed),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

class AudioVolumeSetting extends StatelessWidget {
  const AudioVolumeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ZikrAudioPlayerCubit>();

    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      buildWhen: (a, b) => a.volume != b.volume,
      builder: (context, state) {
        return AudioSettingCard(
          icon: state.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          title: S.of(context).audioPlayerVolume,
          value: "${(state.volume * 100).round()}%",
          child: Row(
            children: [
              const Icon(Icons.volume_mute_rounded, size: 20),
              Expanded(
                child: Slider(
                  value: state.volume.clamp(0.0, 1.0),
                  divisions: 20,
                  onChanged: (value) => cubit.saveSettings(volume: value),
                ),
              ),
              const Icon(Icons.volume_up_rounded, size: 20),
            ],
          ),
        );
      },
    );
  }
}

class AudioDelaySetting extends StatelessWidget {
  const AudioDelaySetting({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ZikrAudioPlayerCubit>();

    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      buildWhen: (a, b) => a.delayType != b.delayType || a.delayDuration != b.delayDuration,
      builder: (context, state) {
        final options = {
          AudioDelayTypeEnum.none: s.audioPlayerDelayNone,
          AudioDelayTypeEnum.byPreviousZikr: s.audioPlayerDelayByPrevious,
          AudioDelayTypeEnum.fixedTime: s.audioPlayerDelayFixed,
        };
        final isFixed = state.delayType == AudioDelayTypeEnum.fixedTime;

        return AudioSettingCard(
          icon: Icons.timer_outlined,
          title: s.audioPlayerDelay,
          value: isFixed ? "${state.delayDuration} ${s.audioPlayerDelaySeconds}" : "",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final option in options.entries)
                    ChoiceChip(
                      label: Text(option.value),
                      selected: state.delayType == option.key,
                      onSelected: (_) => cubit.saveSettings(delayType: option.key),
                    ),
                ],
              ),
              if (isFixed)
                Slider(
                  value: state.delayDuration.toDouble().clamp(1, 15),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  onChanged: (value) => cubit.saveSettings(delayDuration: value.toInt()),
                ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

/// Opens the reciter and downloads sheet; shows the reciter that is selected.
class ReciterEntryCard extends StatefulWidget {
  const ReciterEntryCard({super.key});

  @override
  State<ReciterEntryCard> createState() => _ReciterEntryCardState();
}

class _ReciterEntryCardState extends State<ReciterEntryCard> {
  @override
  Widget build(BuildContext context) {
    final reciter = sl<ReciterAudioRepo>().getReciter();

    return OutlinedSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListTile(
        leading: const Icon(Icons.record_voice_over_rounded),
        title: Text(S.of(context).downloadCenter),
        subtitle: Text(reciter.localizedName(context)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const DownloadCenterScreen()),
          );
          // The reciter may have changed there.
          if (mounted) setState(() {});
        },
      ),
    );
  }
}
