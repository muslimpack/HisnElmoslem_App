import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  void push(Widget route) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) {
          return route;
        },
      ),
    );
  }
}
