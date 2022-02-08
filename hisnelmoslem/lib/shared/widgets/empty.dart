import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String imagePath, title, description;
  final bool isImage;
  final IconData icon;
  final double iconSize;
  const Empty({
    Key? key,
    this.imagePath = "assets/images/app_icon.png",
    this.title = "",
    this.description = "",
    this.isImage = true,
    this.icon = Icons.featured_play_list,
    this.iconSize = 90,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath == ""
                ? SizedBox()
                : isImage
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(imagePath),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                      ),
            title == ""
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            description == ""
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        wordSpacing: 7,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
