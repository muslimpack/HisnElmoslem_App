// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/color_swatch_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';

class ShareImageSettingsEditor extends StatelessWidget {
  final BuildContext context;
  const ShareImageSettingsEditor({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final ShareImageCubit shareImageCubit = context.read<ShareImageCubit>();
    return BlocBuilder<ShareImageCubit, ShareImageState>(
      bloc: shareImageCubit,
      builder: (context, state) {
        if (state is! ShareImageLoadedState) {
          return const Loading();
        }
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          contentPadding: EdgeInsets.zero,
          title: Text(S.of(context).settings),
          content: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            height: 450,
            width: 350,
            child: ListView(
              padding: const EdgeInsets.all(15),
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                ColorSwatchBuilder(
                  title: S.of(context).titleColor,
                  apply: (color) {
                    shareImageCubit.updateTitleColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.titleTextColor,
                ),
                ColorSwatchBuilder(
                  title: S.of(context).textColor,
                  apply: (color) {
                    shareImageCubit.updateTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.bodyTextColor,
                ),
                ColorSwatchBuilder(
                  title: S.of(context).subtitleColor,
                  apply: (color) {
                    shareImageCubit.updateAdditionalTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.additionalTextColor,
                ),
                ColorSwatchBuilder(
                  title: S.of(context).backgroundColor,
                  apply: (color) {
                    shareImageCubit.updateBackgroundColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.backgroundColor,
                ),
                const Divider(),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: Text(S.of(context).showZikrIndex),
                      selected: state.shareImageSettings.showZikrIndex,
                      onSelected: (value) {
                        shareImageCubit.updateShowZikrIndex(
                          value: value,
                        );
                      },
                    ),
                    ChoiceChip(
                      label: Text(S.of(context).showFadl),
                      selected: state.shareImageSettings.showFadl,
                      onSelected: (value) {
                        shareImageCubit.uodateShowFadl(value: value);
                      },
                    ),
                    ChoiceChip(
                      label: Text(S.of(context).showSourceOfZikr),
                      selected: state.shareImageSettings.showSource,
                      onSelected: (value) {
                        shareImageCubit.updateShowSource(value: value);
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  S.of(context).imageQuality,
                ),
                const SizedBox(height: 10),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: List.generate(
                    kShareImageQualityList.length,
                    (index) {
                      return ChoiceChip(
                        selected: kShareImageQualityList[index] ==
                            state.shareImageSettings.imageQuality,
                        onSelected: (val) {
                          shareImageCubit.updateImageQuality(
                            kShareImageQualityList[index],
                          );
                        },
                        label: Text(
                          kShareImageQualityList[index].toString(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
