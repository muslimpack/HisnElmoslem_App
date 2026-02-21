import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DrawerCard(
            child: ListTile(
              leading: const Icon(Icons.close),
              title: Text(S.of(context).close),
              onTap: () {
                ZoomDrawer.of(context)?.toggle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
