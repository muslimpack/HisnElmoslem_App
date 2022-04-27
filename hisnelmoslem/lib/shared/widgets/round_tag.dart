import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

class RoundTagCard extends StatelessWidget {
  final String? name;
  final Color color;

  const RoundTagCard({Key? key, required this.name, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: FittedBox(
            child: Text(name ?? "",
                style: TextStyle(fontSize: 12, color: white),
                textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
  }
}
