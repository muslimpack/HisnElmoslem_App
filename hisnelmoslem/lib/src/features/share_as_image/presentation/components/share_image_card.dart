import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';

class ShareImageCard extends StatelessWidget {
  const ShareImageCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) {
          return const Loading();
        }

        final dbContent = state.content;
        return Container(
          margin: EdgeInsets.zero,
          color: state.shareImageSettings.backgroundColor,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  color: state.shareImageSettings.titleTextColor,
                  thickness: state.dividerSize,
                  height: 0,
                ),
                ListView(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    /// Content
                    ZikrContentBuilder(
                      dbContent: dbContent,
                      enableDiacritics:
                          !state.shareImageSettings.removeDiacritics,
                      fontSize: state.shareImageSettings.fontSize,
                      color: state.shareImageSettings.bodyTextColor,
                    ),

                    /// Count
                    if (dbContent.count > 1) ...[
                      const SizedBox(height: 25),
                      Text(
                        "${S.of(context).count}: ${dbContent.count}",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state.shareImageSettings.bodyTextColor,
                          fontSize: state.shareImageSettings.fontSize *
                              state.fadlFactor,
                        ),
                      ),
                    ],

                    /// Fadl
                    if ((dbContent.fadl.isNotEmpty) &&
                        state.shareImageSettings.showFadl) ...[
                      const SizedBox(height: 25),
                      Text(
                        dbContent.fadl,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state.shareImageSettings.additionalTextColor,
                          fontSize: state.shareImageSettings.fontSize *
                              state.fadlFactor,
                        ),
                      ),
                    ],

                    /// Source
                    if ((dbContent.source.isNotEmpty) &&
                        state.shareImageSettings.showSource) ...[
                      const SizedBox(height: 25),
                      Text(
                        dbContent.source,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state.shareImageSettings.additionalTextColor,
                          fontSize: state.shareImageSettings.fontSize *
                              state.sourceFactor,
                        ),
                      ),
                    ],
                  ],
                ),

                Divider(
                  color: state.shareImageSettings.titleTextColor,
                  thickness: state.dividerSize,
                ),

                /// Bottom
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
                          fontSize: 20 * state.titleFactor * 1.5,
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
