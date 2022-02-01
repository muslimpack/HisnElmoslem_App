import 'package:flutter/material.dart';

class RoundTagCard extends StatelessWidget {
  final String name;
  final Color color;

  const RoundTagCard({Key? key, required this.name, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(name,
            style: TextStyle(fontSize: 12), textDirection: TextDirection.ltr),
      ),
    );
  }
}
