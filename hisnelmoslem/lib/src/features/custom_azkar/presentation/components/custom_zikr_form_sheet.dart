import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/count_stepper.dart';

/// Create or edit a custom zikr.
class CustomZikrForm extends StatefulWidget {
  final CustomZikr? zikr;
  const CustomZikrForm({super.key, this.zikr});

  /// Resolves to the edited [CustomZikr] (not yet saved), or `null` if dismissed.
  static Future<CustomZikr?> show(BuildContext context, {CustomZikr? zikr}) {
    return showModalBottomSheet<CustomZikr>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CustomZikrForm(zikr: zikr),
    );
  }

  @override
  State<CustomZikrForm> createState() => _CustomZikrFormState();
}

class _CustomZikrFormState extends State<CustomZikrForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _content = TextEditingController(text: widget.zikr?.content);
  late final TextEditingController _source = TextEditingController(text: widget.zikr?.source);
  late final TextEditingController _fadl = TextEditingController(text: widget.zikr?.fadl);
  late int _count = widget.zikr?.defaultCount ?? 1;

  @override
  void dispose() {
    _content.dispose();
    _source.dispose();
    _fadl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final base = widget.zikr ?? const CustomZikr(content: "");
    Navigator.pop(
      context,
      base.copyWith(
        content: _content.text,
        source: _source.text,
        fadl: _fadl.text,
        defaultCount: _count,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.zikr == null ? s.newZikr : s.edit,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _content,
                autofocus: true,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.zikrText,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? "").trim().isEmpty ? s.zikrTextRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _source,
                decoration: InputDecoration(
                  labelText: s.zikrSource,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fadl,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: s.zikrFadl,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(s.zikrCountLabel)),
                  CountStepper(value: _count, onChanged: (v) => setState(() => _count = v)),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _submit, child: Text(s.save)),
            ],
          ),
        ),
      ),
    );
  }
}
