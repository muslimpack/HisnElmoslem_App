import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          String Function(int) label, {
          required String fieldLabel,
        }) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in values)
                      ChoiceChip(
                        label: Text(label(value).toArabicNumber()),
                        selected: limit.value == value,
                        onSelected: (_) => audio.setLimit(
                          TallySessionLimit.tryParse(limit.type, '$value')!,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _LimitValueField(
                  // A new field when the kind of limit changes.
                  key: ValueKey(limit.type),
                  type: limit.type,
                  value: limit.value,
                  label: fieldLabel,
                  onValid: audio.setLimit,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          // Keeps the number field above the keyboard.
          padding: EdgeInsets.fromLTRB(12, 0, 12, 24 + MediaQuery.viewInsetsOf(context).bottom),
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
                        (v) => s.tallyMinutesShort(v),
                        fieldLabel: s.tallyHowManyMinutes,
                      ),
                    RadioListTile<TallySessionLimitType>(
                      value: TallySessionLimitType.count,
                      title: Text(s.tallySessionCount),
                    ),
                    if (limit.type == TallySessionLimitType.count)
                      presets(
                        TallySessionLimit.countPresets,
                        (v) => '$v',
                        fieldLabel: s.tallyHowManyCounts,
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

/// Any number of minutes or counts, not only the presets. A value is used as soon as it
/// is valid; the field follows the chips when one of them is tapped.
class _LimitValueField extends StatefulWidget {
  final TallySessionLimitType type;
  final int value;
  final String label;
  final ValueChanged<TallySessionLimit> onValid;

  const _LimitValueField({
    super.key,
    required this.type,
    required this.value,
    required this.label,
    required this.onValid,
  });

  @override
  State<_LimitValueField> createState() => _LimitValueFieldState();
}

class _LimitValueFieldState extends State<_LimitValueField> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');
  String? _error;

  int get _max => widget.type == TallySessionLimitType.minutes
      ? TallySessionLimit.maxMinutes
      : TallySessionLimit.maxCount;

  @override
  void didUpdateWidget(_LimitValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A preset was tapped: show it, unless it is what the user just typed.
    if (widget.value != oldWidget.value && int.tryParse(_controller.text) != widget.value) {
      _controller.text = '${widget.value}';
      _error = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    final limit = TallySessionLimit.tryParse(widget.type, text);
    setState(() => _error = limit == null ? S.of(context).tallyValueBetween(1, _max) : null);
    if (limit != null) widget.onValid(limit);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _error,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: _changed,
    );
  }
}
