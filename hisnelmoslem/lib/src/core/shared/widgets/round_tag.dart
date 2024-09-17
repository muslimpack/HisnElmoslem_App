import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';

class RoundTagCard extends StatelessWidget {
  final String name;
  final Color color;

  const RoundTagCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: color,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
              color: color.getContrastColor,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
