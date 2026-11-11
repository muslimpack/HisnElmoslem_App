import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

/// − [count] + control. Tapping the number lets the user type a value.
class CountStepper extends StatelessWidget {
  static const int min = 1;
  static const int max = 9999;

  final int value;
  final ValueChanged<int> onChanged;

  const CountStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: S.of(context).countDecrease,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final result = await CountInputDialog.show(context, initial: value);
              if (result != null) onChanged(result);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 32),
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: S.of(context).countIncrease,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class CountInputDialog extends StatefulWidget {
  final int initial;
  const CountInputDialog({super.key, required this.initial});

  /// Resolves to the typed count, or `null` if dismissed.
  static Future<int?> show(BuildContext context, {required int initial}) {
    return showDialog<int>(
      context: context,
      builder: (context) => CountInputDialog(initial: initial),
    );
  }

  @override
  State<CountInputDialog> createState() => _CountInputDialogState();
}

class _CountInputDialogState extends State<CountInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    Navigator.pop<int>(context, value?.clamp(CountStepper.min, CountStepper.max));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).zikrCountLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textAlign: TextAlign.center,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
        FilledButton(onPressed: _submit, child: Text(S.of(context).save)),
      ],
    );
  }
}
