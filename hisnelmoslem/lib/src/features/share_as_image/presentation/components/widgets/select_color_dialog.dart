import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';

/// `#RRGGBB`, upper case.
extension ColorHexCode on Color {
  String get hexCode =>
      '#${(toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
}

/// Dialog to pick one color: the saturation/brightness area, a hue slider and a hex
/// field, with the current color next to the new one. Pops with the chosen color.
class SelectColorDialog extends StatefulWidget {
  /// What is being colored, e.g. "Title color".
  final String title;
  final Color color;

  const SelectColorDialog({super.key, required this.title, required this.color});

  /// Resolves to the chosen color, or null when dismissed.
  static Future<Color?> show(
    BuildContext context, {
    required String title,
    required Color color,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (_) => SelectColorDialog(title: title, color: color),
    );
  }

  @override
  State<SelectColorDialog> createState() => _SelectColorDialogState();
}

class _SelectColorDialogState extends State<SelectColorDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.color);
  late final TextEditingController _hex = TextEditingController(text: widget.color.hexCode);

  Color get _color => _hsv.toColor();

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _onPicked(HSVColor value) {
    setState(() => _hsv = value);
    // Keep the field in step with the picker.
    _hex.value = TextEditingValue(
      text: _color.hexCode,
      selection: TextSelection.collapsed(offset: _color.hexCode.length),
    );
  }

  void _onHexChanged(String text) {
    final digits = text.replaceFirst('#', '');
    if (digits.length != 6) return;
    final value = int.tryParse(digits, radix: 16);
    if (value == null) return;
    setState(() => _hsv = HSVColor.fromColor(Color(0xFF000000 | value)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ColorComparison(
                current: widget.color,
                updated: _color,
                currentLabel: s.shareImageColorCurrent,
                updatedLabel: s.shareImageColorNew,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 190,
                  // Saturation across, brightness up, for the hue below.
                  child: ColorPickerArea(_hsv, _onPicked, PaletteType.hsvWithHue),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ColorPickerSlider(
                  TrackType.hue,
                  _hsv,
                  _onPicked,
                  displayThumbColor: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hex,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  labelText: s.shareImageHexCode,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _onHexChanged,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(s.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _color),
                      child: Text(s.selectColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two swatches side by side: the color now and the color being picked.
class ColorComparison extends StatelessWidget {
  final Color current;
  final Color updated;
  final String currentLabel;
  final String updatedLabel;

  const ColorComparison({
    super.key,
    required this.current,
    required this.updated,
    required this.currentLabel,
    required this.updatedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: ColorSwatchLabel(color: current, label: currentLabel),
            ),
            Expanded(
              child: ColorSwatchLabel(color: updated, label: updatedLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSwatchLabel extends StatelessWidget {
  final Color color;
  final String label;

  const ColorSwatchLabel({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final textColor = color.getContrastColor;

    return Container(
      height: 72,
      color: color,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: textColor.withValues(alpha: .8), fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            color.hexCode,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
