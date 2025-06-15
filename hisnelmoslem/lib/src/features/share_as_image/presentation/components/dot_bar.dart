import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';

class DotBar extends StatelessWidget {
  final int length;
  final int activeIndex;
  final Color? dotColor;
  final bool showNumber;
  const DotBar({
    super.key,
    required this.length,
    required this.activeIndex,
    this.dotColor,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(
        length,
        (index) => Dot(
          index: index,
          isActive: index == activeIndex,
          color: dotColor,
          showNumber: showNumber,
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool showNumber;
  final Color? color;
  const Dot({
    super.key,
    required this.index,
    required this.isActive,
    required this.showNumber,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = color ?? Theme.of(context).colorScheme.primary;

    if (showNumber) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: CircleAvatar(
          backgroundColor: dotColor,
          child: Text(
            "${index + 1}",
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: dotColor.getContrastColor,
            ),
          ),
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: isActive ? 25 : 10,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: dotColor,
      ),
    );
  }
}
