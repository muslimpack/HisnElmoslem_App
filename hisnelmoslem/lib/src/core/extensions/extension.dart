import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  Future<T?> push<T extends Object?>(Widget route) {
    return Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) {
          return route;
        },
      ),
    );
  }
}
