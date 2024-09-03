import 'package:flutter/material.dart';

class PageSideEffect extends StatelessWidget {
  final int index;

  const PageSideEffect({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
            end: index.isOdd ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              Colors.white,
              Colors.black.withAlpha(200),
            ],
          ),
        ),
      ),
    );
  }
}
