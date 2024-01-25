import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/services.dart';

void main() async {
  await initServices();
  runApp(const MyApp());
}
