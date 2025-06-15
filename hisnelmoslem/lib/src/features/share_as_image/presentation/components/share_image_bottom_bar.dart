import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShareImageBottomBar extends StatelessWidget {
  const ShareImageBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ShareImageCubit shareImageCubit = context.read<ShareImageCubit>();
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: S.of(context).showDiacritics,
            icon: Icon(MdiIcons.abjadArabic),
            onPressed: () {
              shareImageCubit.toggleRemoveDiacritics();
            },
          ),
        ],
      ),
    );
  }
}
