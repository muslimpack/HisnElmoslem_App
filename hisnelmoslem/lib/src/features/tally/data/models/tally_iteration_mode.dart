import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';

enum TallyIterationMode { shuffle, circular, none }

extension TallyIterationModeExtension on TallyIterationMode {
  String localeName(BuildContext context) {
    switch (this) {
      case TallyIterationMode.shuffle:
        return S.of(context).shuffle;
      case TallyIterationMode.circular:
        return S.of(context).circular;
      case TallyIterationMode.none:
        return S.of(context).none;
    }
  }
}
