import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/image_var_font_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/settings_sheet.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/share_as_image_controller.dart';
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
                    style: const TextStyle(
                      fontFamily: "Uthmanic",
                    ),
                  ),
                  centerTitle: true,
                  actions: [
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
                            color: mainColor,
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
                        child: RepaintBoundary(
                          key: controller.imageKey,
                          child: ImageVarFontBuilder(
                            key: GlobalKey(),
                            dbContent: controller.dbContent,
                          ),
                        ),
                      ),
                      SettingsSheet(
                        shareAsImageController: controller,
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
                        icon: const Icon(MdiIcons.restart),
                        onPressed: () {
                          controller.resetFontSize();
                        },
                      ),
                      IconButton(
                        icon: const Icon(MdiIcons.formatFontSizeIncrease),
                        onPressed: () {
                          controller.increaseFontSize();
                        },
                      ),
                      IconButton(
                        icon: const Icon(MdiIcons.formatFontSizeDecrease),
                        onPressed: () {
                          controller.decreaseFontSize();
                        },
                      ),
                      IconButton(
                        icon: const Icon(MdiIcons.abjadArabic),
                        onPressed: () {
                          controller.toggleRemoveTashkel();
                        },
                      ),
                      IconButton(
                        onPressed: () async {
                          controller.showImageWidthDialog();
                        },
                        icon: const Icon(MdiIcons.resize),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
