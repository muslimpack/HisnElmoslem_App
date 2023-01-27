import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';

class Empty extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final bool isImage;
  final IconData icon;
  final double iconSize;
  final Function()? onButtonCLick;

  const Empty({
    super.key,
    this.imagePath = "assets/images/app_icon.png",
    this.title = "",
    this.description = "",
    this.isImage = true,
    this.icon = Icons.featured_play_list,
    this.iconSize = 90,
    this.onButtonCLick,
    this.buttonText = "اضغط هنا",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScrollGlowRemover(
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath == ""
                ? const SizedBox()
                : isImage
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          imagePath,
                          width: 50,
                        ),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                      ),
            title == ""
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            description == ""
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        wordSpacing: 7,
                      ),
                    ),
                  ),
            onButtonCLick != null
                ? TextButton(onPressed: onButtonCLick!, child: Text(buttonText))
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
