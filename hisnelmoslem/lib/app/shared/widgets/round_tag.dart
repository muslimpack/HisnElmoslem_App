import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class RoundTagCard extends StatelessWidget {
  final String? name;
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
      child: SizedBox(
        height: 30,
        child: Center(
          child: Text(
            name ?? "",
            style: TextStyle(
              fontSize: 15,
              color: white,
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
