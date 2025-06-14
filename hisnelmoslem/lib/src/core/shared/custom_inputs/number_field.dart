import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/custom_field_decoration.dart';

class UserNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final IconData? leadingIcon;

  const UserNumberField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: TextInputType.number,

        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChange,
        decoration: customInputDecoration.copyWith(
          hintText: hintText,
          labelText: hintText,
          prefixIcon: Icon(leadingIcon),
        ),
      ),
    );
  }
}

class UserNumberFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final IconData? leadingIcon;
  final String? Function(String?)? validator;

  const UserNumberFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.leadingIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: TextInputType.number,

        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChange,
        decoration: customInputDecoration.copyWith(
          hintText: hintText,
          labelText: hintText,
          prefixIcon: Icon(leadingIcon),
        ),
        validator: validator,
      ),
    );
  }
}
