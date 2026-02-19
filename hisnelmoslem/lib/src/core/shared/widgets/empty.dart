import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final bool isImage;
  final IconData? icon;
  final double iconSize;
  final bool isItemList;
  final Function()? onButtonCLick;

  const Empty({
    super.key,
    this.imagePath = "assets/images/app_icon.png",
    this.title = "",
    this.description = "",
    this.isImage = true,
    this.icon,
    this.iconSize = 90,
    this.onButtonCLick,
    this.isItemList = false,
    this.buttonText = "اضغط هنا",
  });

  @override
  Widget build(BuildContext context) {
    final List<String> items = description.split("\n").fold([], (previousValue, element) {
      if (element.isNotEmpty) {
        return previousValue..add(element.trim());
      }
      return previousValue;
    });
    return Center(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        // mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isImage)
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(height: 250, child: Image.asset(imagePath, fit: BoxFit.fitHeight)),
            ),
          if (icon != null) Icon(icon, size: iconSize),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25)),
            ),
          if (description.isNotEmpty)
            if (!isItemList)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 2),
                ),
              )
            else
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: Card(
                      color: Theme.of(context).colorScheme.primary.withAlpha(50),
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("${index + 1}", textAlign: TextAlign.center)),
                      ),
                    ),
                    title: Text(item),
                  ),
                );
              }),
          if (onButtonCLick != null)
            TextButton(onPressed: onButtonCLick, child: Text(buttonText))
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
