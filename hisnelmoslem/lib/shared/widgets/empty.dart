import 'package:flutter/widgets.dart';

class Empty extends StatelessWidget {
  final String imagePath, title, description;
  const Empty({
    Key? key,
    this.imagePath = "assets/images/app_icon.png",
    this.title = "",
    this.description = "",
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
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(imagePath),
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
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
