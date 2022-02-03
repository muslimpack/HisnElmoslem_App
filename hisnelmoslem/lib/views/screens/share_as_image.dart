import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';

class ShareAsImage extends StatelessWidget {
  final DbContent dbContent;
  ShareAsImage({Key? key, required this.dbContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TransformationController? transformationController =
        new TransformationController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("مشاركة الذكر كصورة"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onDoubleTap: () {
          transformationController.value = Matrix4.identity();
        },
        child: InteractiveViewer(
            transformationController: transformationController,
            minScale: 0.25,
            maxScale: 2,
            clipBehavior: Clip.antiAlias,
            boundaryMargin: EdgeInsets.all(100),
            panEnabled: true,
            child: ImageBuilder(dbContent: dbContent)),
      ),
    );
  }
}

class ImageBuilder extends StatelessWidget {
  final DbContent dbContent;
  ImageBuilder({
    Key? key,
    required this.dbContent,
  }) : super(key: key);

  DashboardController dashboardController = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.white.withAlpha(50),
          child: Stack(
            children: [
              // Image.asset("assets/images/app_icon.png"),
              //
              Positioned(
                top: 10,
                width: screenWidth,
                child: Container(
                  child: Text(
                    "${dashboardController.allTitle[dbContent.titleId - 1].name} - ذكر رقم ${dbContent.orderId}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Uthmanic",
                        fontSize: 15),
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                width: screenWidth,
                child: Container(
                  child: Text(
                    "بواسطة تطبيق حصن المسلم 2022",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Uthmanic",
                        fontSize: 15),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  top: 40,
                  right: 60,
                  left: 60,
                ),
                child: Container(
                  color: Colors.blue.withAlpha(50),
                  child: SizedBox(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: AutoSizeText(
                          dbContent.content,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          minFontSize: 10,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                width: screenWidth,
                child: Container(
                  child: Container(
                    color: Colors.red.withAlpha(50),
                    child: SizedBox(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: AutoSizeText(
                            dbContent.fadl,
                            softWrap: true,
                            minFontSize: 10,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //
              Positioned(
                  top: 10,
                  right: 10,
                  width: 50,
                  child: Image.asset("assets/images/app_icon.png")),
            ],
          ),
        ),
      ),
    );
  }
}
