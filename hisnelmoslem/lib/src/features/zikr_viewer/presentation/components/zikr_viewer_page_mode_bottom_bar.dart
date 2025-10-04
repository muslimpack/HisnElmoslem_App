import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/navigation_slider.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: NavigationSlider()),
        ],
      ),
    );
  }
}
