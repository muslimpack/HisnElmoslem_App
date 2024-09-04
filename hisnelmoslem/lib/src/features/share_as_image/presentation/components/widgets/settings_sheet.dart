import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_data.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/color_swatch_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';

class ShareImageSettingsEditor extends StatelessWidget {
  const ShareImageSettingsEditor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) {
          return const Loading();
        }
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          contentPadding: EdgeInsets.zero,
          title: Text("settings".tr),
          content: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            height: 450,
            width: 300,
            child: ListView(
              padding: const EdgeInsets.all(15),
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                ColorSwatchBuilder(
                  title: "title color".tr,
                  apply: (color) {
                    context.read<ShareImageCubit>().updateTitleColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: shareAsImageData.titleTextColor,
                ),
                ColorSwatchBuilder(
                  title: "text color".tr,
                  apply: (color) {
                    context.read<ShareImageCubit>().updateTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: shareAsImageData.bodyTextColor,
                ),
                ColorSwatchBuilder(
                  title: "subtitle color".tr,
                  apply: (color) {
                    context
                        .read<ShareImageCubit>()
                        .updateAdditionalTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: shareAsImageData.additionalTextColor,
                ),
                ColorSwatchBuilder(
                  title: "background color".tr,
                  apply: (color) {
                    context
                        .read<ShareImageCubit>()
                        .updateBackgroundColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: shareAsImageData.backgroundColor,
                ),
                const Divider(),
                CheckboxListTile(
                  title: Text("show zikr index".tr),
                  value: shareAsImageData.showZikrIndex,
                  onChanged: (value) {
                    context.read<ShareImageCubit>().updateShowZikrIndex(
                          value: value!,
                        );
                  },
                ),
                CheckboxListTile(
                  title: Text("show fadl".tr),
                  value: shareAsImageData.showFadl,
                  onChanged: (value) {
                    context
                        .read<ShareImageCubit>()
                        .uodateShowFadl(value: value!);
                  },
                ),
                CheckboxListTile(
                  title: Text("show source of zikr".tr),
                  value: shareAsImageData.showSource,
                  onChanged: (value) {
                    context
                        .read<ShareImageCubit>()
                        .updateShowSource(value: value!);
                  },
                ),
                const Divider(),
                Text(
                  "image quality".tr,
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      kShareImageQualityList.length,
                      (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            selected: kShareImageQualityList[index] ==
                                shareAsImageData.imageQuality,
                            onSelected: (val) {
                              context
                                  .read<ShareImageCubit>()
                                  .updateImageQuality(
                                    kShareImageQualityList[index],
                                  );
                            },
                            label: Text(
                              kShareImageQualityList[index].toString(),
                            ),
                          ),
                        );
                      },
                    ),
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
