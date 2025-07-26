import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

class NoItemsFoundIndicatorBuilder extends StatelessWidget {
  final String searchText;
  const NoItemsFoundIndicatorBuilder({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search),
        const SizedBox(height: 10),
        Text(
          '${S.of(context).noResultsFound}\n"$searchText"',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
