import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              thickness: 5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const Expanded(
            child: Divider(
              thickness: 5,
            ),
          ),
        ],
      ),
    );
  }
}
