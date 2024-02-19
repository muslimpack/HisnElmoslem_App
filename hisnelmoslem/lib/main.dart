import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app/app.dart';
import 'package:hisnelmoslem/app/init_services.dart';

void main() async {
  await initServices();

  runApp(const MyApp());
}
