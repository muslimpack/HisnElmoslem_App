import 'package:flutter/material.dart';

extension RichTextExt on RichText {
  String toPlainText() {
    final buffer = StringBuffer();
    (text as TextSpan).computeToPlainText(buffer);
    return buffer.toString();
  }
}
