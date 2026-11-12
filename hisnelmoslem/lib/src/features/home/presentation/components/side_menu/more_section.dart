import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/about/presentation/screens/about_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MoreSection extends StatelessWidget {
  const MoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DrawerReveal(
          order: 6,
          child: DrawerTile(
            icon: MdiIcons.gmail,
            title: S.of(context).contactDev,
            onTap: EmailManager.messageUS,
          ),
        ),
        DrawerReveal(
          order: 7,
          child: DrawerTile(
            icon: MdiIcons.web,
            title: S.of(context).moreApps,
            onTap: () => openURL(kOrgWebsite),
          ),
        ),
        DrawerReveal(
          order: 8,
          child: DrawerTile(
            icon: Icons.info_rounded,
            title: S.of(context).aboutUs,
            onTap: () => context.push(const AboutScreen()),
          ),
        ),
      ],
    );
  }
}
