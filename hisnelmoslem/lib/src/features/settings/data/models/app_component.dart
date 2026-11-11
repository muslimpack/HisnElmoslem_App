import 'package:flutter/widgets.dart';

class AppComponent {
  final String Function(BuildContext context) title;
  final IconData icon;
  final Widget widget;

  const AppComponent({required this.title, required this.icon, required this.widget});
}
