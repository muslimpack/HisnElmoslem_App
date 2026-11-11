import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';

/// When the voice playback stops by itself: never, after some minutes, or after a
/// number of counts.
class TallySessionSheet extends StatelessWidget {
  const TallySessionSheet({super.key});

  static Future<void> show(BuildContext context) {
    final audio = context.read<TallyAudioCubit>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: audio,
        child: const SafeArea(top: false, child: TallySessionSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<TallyAudioCubit, TallyAudioState>(
      buildWhen: (a, b) => a.limit != b.limit,
      builder: (context, state) {
        final audio = context.read<TallyAudioCubit>();
        final limit = state.limit;

        Widget presets(
          List<int> values,
          TallySessionLimit Function(int) make,
          String Function(int) label,
        ) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final value in values)
                  ChoiceChip(
                    label: Text(label(value).toArabicNumber()),
                    selected: limit.value == value,
                    onSelected: (_) => audio.setLimit(make(value)),
                  ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(s.tallySession, style: theme.textTheme.titleLarge),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Text(
                  s.tallySessionDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              RadioGroup<TallySessionLimitType>(
                groupValue: limit.type,
                onChanged: (type) {
                  if (type == null) return;
                  audio.setLimit(switch (type) {
                    TallySessionLimitType.endless => const TallySessionLimit.endless(),
                    TallySessionLimitType.minutes => TallySessionLimit.minutes(
                      TallySessionLimit.minutePresets[1],
                    ),
                    TallySessionLimitType.count => TallySessionLimit.count(
                      TallySessionLimit.countPresets[1],
                    ),
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<TallySessionLimitType>(
                      value: TallySessionLimitType.endless,
                      title: Text(s.tallySessionEndless),
                    ),
                    RadioListTile<TallySessionLimitType>(
                      value: TallySessionLimitType.minutes,
                      title: Text(s.tallySessionMinutes),
                    ),
                    if (limit.type == TallySessionLimitType.minutes)
                      presets(
                        TallySessionLimit.minutePresets,
                        TallySessionLimit.minutes,
                        (v) => s.tallyMinutesShort(v),
                      ),
                    RadioListTile<TallySessionLimitType>(
                      value: TallySessionLimitType.count,
                      title: Text(s.tallySessionCount),
                    ),
                    if (limit.type == TallySessionLimitType.count)
                      presets(
                        TallySessionLimit.countPresets,
                        TallySessionLimit.count,
                        (v) => '$v',
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
