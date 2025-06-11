import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/dialogs/image_width_dialog.dart';
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
            tooltip: S.of(context).fontResetSize,
            icon: Icon(MdiIcons.restart),
            onPressed: () {
              shareImageCubit.resetFontSize();
            },
          ),
          IconButton(
            tooltip: S.of(context).fontIncreaseSize,
            icon: Icon(MdiIcons.formatFontSizeIncrease),
            onPressed: () {
              shareImageCubit.increaseFontSize();
            },
          ),
          IconButton(
            tooltip: S.of(context).fontDecreaseSize,
            icon: Icon(MdiIcons.formatFontSizeDecrease),
            onPressed: () {
              shareImageCubit.decreaseFontSize();
            },
          ),
          IconButton(
            tooltip: S.of(context).showDiacritics,
            icon: Icon(MdiIcons.abjadArabic),
            onPressed: () {
              shareImageCubit.toggleRemoveDiacritics();
            },
          ),
          IconButton(
            onPressed: () async {
              final state = shareImageCubit.state;
              if (state is! ShareImageLoadedState) return;
              await showDialog(
                context: context,
                builder: (BuildContext _) {
                  return ImageWidthDialog(
                    initialValue: state.shareImageSettings.imageWidth
                        .toString(),
                    onSubmit: (width) async {
                      final int? tempWidth = int.tryParse(width);

                      if (tempWidth == null) return;
                      await shareImageCubit.updateImageWidth(value: tempWidth);
                    },
                  );
                },
              );
            },
            icon: Icon(MdiIcons.resize),
          ),
        ],
      ),
    );
  }
}
