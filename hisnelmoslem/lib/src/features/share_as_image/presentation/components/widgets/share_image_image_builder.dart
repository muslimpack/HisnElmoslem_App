import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';

class ShareImageImageBuilder extends StatelessWidget {
  const ShareImageImageBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareImageCubit, ShareImageState>(
      bloc: context.read<ShareImageCubit>(),
      builder: (context, state) {
        if (state is! ShareImageLoadedState) {
          return const Loading();
        }

        final dbContent = state.content;
        return Card(
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.zero,
          color: state.shareImageSettings.backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: SizedBox(
            width: state.shareImageSettings.imageWidth.toDouble(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.getImageTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: state.shareImageSettings.titleTextColor,
                      fontSize:
                          state.shareImageSettings.fontSize * state.titleFactor,
                    ),
                  ),
                ),
                Divider(
                  color: state.shareImageSettings.titleTextColor,
                  thickness: state.dividerSize,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ZikrContentBuilder(
                          dbContent: dbContent,
                          enableDiacritics:
                              !state.shareImageSettings.removeDiacritics,
                          fontSize: state.shareImageSettings.fontSize,
                          color: state.shareImageSettings.bodyTextColor,
                        ),
                      ),
                      // Fadl
                      if (!(dbContent.fadl == "") &&
                          state.shareImageSettings.showFadl)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            dbContent.fadl,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  state.shareImageSettings.additionalTextColor,
                              fontSize: state.shareImageSettings.fontSize *
                                  state.fadlFactor,
                            ),
                          ),
                        ),
                      // Source
                      if (!(dbContent.source == "") &&
                          state.shareImageSettings.showSource)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            dbContent.source,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  state.shareImageSettings.additionalTextColor,
                              fontSize: state.shareImageSettings.fontSize *
                                  state.sourceFactor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Divider(
                  color: state.shareImageSettings.titleTextColor,
                  thickness: state.dividerSize,
                ),
                //Bottom
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40 * state.titleFactor * 1.5,
                        child: Image.asset("assets/images/app_icon.png"),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        "تطبيق حصن المسلم",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state.shareImageSettings.titleTextColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
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
