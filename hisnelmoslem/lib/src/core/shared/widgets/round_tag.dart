import 'package:flutter/material.dart';

class RoundTagCard extends StatelessWidget {
  final String? name;
  final Color color;

  const RoundTagCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: color,
      child: SizedBox(
        height: 30,
        child: Center(
          child: Text(
            name ?? "",
            style: const TextStyle(
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
