import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/custom_field_decoration.dart';

class UserTextField extends StatelessWidget {
  final bool autoFocus;
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;

  const UserTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        controller: controller,
        onChanged: onChange,
        decoration: customInputDecoration.copyWith(
          hintText: hintText,
          labelText: hintText,
        ),
      ),
    );
  }
}

class UserTextFormField extends StatelessWidget {
  final bool autoFocus;
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final String? Function(String?)? validator;

  const UserTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.validator,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        controller: controller,
        onChanged: onChange,
        decoration: customInputDecoration.copyWith(
          hintText: hintText,
          labelText: hintText,
        ),
        validator: validator,
      ),
    );
  }
}
