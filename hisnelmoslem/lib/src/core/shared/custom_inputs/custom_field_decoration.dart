import 'package:flutter/material.dart';

const InputDecoration customInputDecoration = InputDecoration(
  filled: true,
  // fillColor: HexColor("#1A1A1A"),
  errorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  border: InputBorder.none,
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
);
