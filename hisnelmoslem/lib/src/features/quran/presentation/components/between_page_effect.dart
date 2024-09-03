import 'package:flutter/material.dart';

class BetweenPageEffect extends StatelessWidget {
  final int index;

  const BetweenPageEffect({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
            end: index.isOdd ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(.05),
              Colors.black.withOpacity(.1),
            ],
          ),
        ),
      ),
    );
  }
}
