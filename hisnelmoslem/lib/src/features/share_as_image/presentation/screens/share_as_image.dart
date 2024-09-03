import 'package:capture_widget/core/capture_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/image_var_font_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/settings_sheet.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/share_as_image_controller.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShareAsImage extends StatelessWidget {
  final DbContent dbContent;

  const ShareAsImage({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShareAsImageController>(
      init: ShareAsImageController(dbContent: dbContent),
      builder: (controller) {
        return controller.pageIsLoading
            ? const Loading()
            : Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  elevation: 0,
                  title: Text(
                    "share as image".tr,
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () async {
                        await showDialog(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Center(
                              child: SizedBox(
                                width: 350,
                                height: 450,
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  elevation: 10,
                                  child: ShareAsImageSettings(
                                    shareAsImageController: controller,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.style),
                    ),
                    IconButton(
                      onPressed: () async {
                        controller.shareImage();
                      },
                      icon: const Icon(Icons.share),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize:
                        Size.fromHeight(!controller.isLoading ? 0 : 20),
                    child: !controller.isLoading
                        ? const SizedBox()
                        : LinearProgressIndicator(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            minHeight: 15,
                          ),
                  ),
                ),
                body: GestureDetector(
                  onDoubleTap: () {
                    controller.fitImageToScreen();
                  },
                  child: Stack(
                    children: [
                      InteractiveViewer(
                        constrained: false,
                        // clipBehavior: Clip.none,
                        transformationController:
                            controller.transformationController,
                        minScale: 0.25,
                        maxScale: 3,
                        boundaryMargin: const EdgeInsets.all(5000),
                        child: CaptureWidget(
                          controller: controller.captureWidgetController,
                          child: ImageVarFontBuilder(
                            dbContent: controller.dbContent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomSheet: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          controller.shareImage();
                        },
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.restart),
                        onPressed: () {
                          controller.resetFontSize();
                        },
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.formatFontSizeIncrease),
                        onPressed: () {
                          controller.increaseFontSize();
                        },
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.formatFontSizeDecrease),
                        onPressed: () {
                          controller.decreaseFontSize();
                        },
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.abjadArabic),
                        onPressed: () {
                          controller.toggleRemoveDiacritics();
                        },
                      ),
                      IconButton(
                        onPressed: () async {
                          controller.showImageWidthDialog();
                        },
                        icon: Icon(MdiIcons.resize),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
