import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class RoundButton extends StatelessWidget {
  final Widget text;
  final Function onTap;
  final double radius;
  final bool isTransparent;

  const RoundButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.radius = 5.0,
      this.isTransparent = false})
       ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: isTransparent
            ? ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(transparent),
                foregroundColor: MaterialStateProperty.all(mainColor),
              )
            : const ButtonStyle(),
        onPressed: () {
          onTap();
        },
        child: text,
      ),
    );
  }
}
