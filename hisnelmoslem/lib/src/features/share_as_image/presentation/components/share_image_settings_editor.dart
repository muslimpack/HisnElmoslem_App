// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
                    shareImageCubit.updateTitleColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.titleTextColor,
                ),
                ColorSwatchBuilder(
                  title: "text color".tr,
                  apply: (color) {
                    shareImageCubit.updateTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.bodyTextColor,
                ),
                ColorSwatchBuilder(
                  title: "subtitle color".tr,
                  apply: (color) {
                    shareImageCubit.updateAdditionalTextColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.additionalTextColor,
                ),
                ColorSwatchBuilder(
                  title: "background color".tr,
                  apply: (color) {
                    shareImageCubit.updateBackgroundColor(color);
                  },
                  colorSwatchList: kShareImageColorsList,
                  colorToTrack: state.shareImageSettings.backgroundColor,
                ),
                const Divider(),
                CheckboxListTile(
                  title: Text("show zikr index".tr),
                  value: state.shareImageSettings.showZikrIndex,
                  onChanged: (value) {
                    shareImageCubit.updateShowZikrIndex(
                      value: value!,
                    );
                  },
                ),
                CheckboxListTile(
                  title: Text("show fadl".tr),
                  value: state.shareImageSettings.showFadl,
                  onChanged: (value) {
                    shareImageCubit.uodateShowFadl(value: value!);
                  },
                ),
                CheckboxListTile(
                  title: Text("show source of zikr".tr),
                  value: state.shareImageSettings.showSource,
                  onChanged: (value) {
                    shareImageCubit.updateShowSource(value: value!);
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
                                state.shareImageSettings.imageQuality,
                            onSelected: (val) {
                              shareImageCubit.updateImageQuality(
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
