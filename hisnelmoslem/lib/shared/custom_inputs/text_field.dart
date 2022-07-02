import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

class UserTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;

  const UserTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          textAlign: TextAlign.center,
          controller: controller,
          // autofocus: true,

          onChanged: onChange,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black45,
            border: InputBorder.none,
            // focusedBorder: InputBorder.none,

            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: hintText,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: mainColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding:
                const EdgeInsets.only(left: 15, bottom: 5, top: 5, right: 15),
          )),
    );
  }
}
