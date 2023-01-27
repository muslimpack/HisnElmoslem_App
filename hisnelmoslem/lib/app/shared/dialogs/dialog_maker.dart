import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class DialogMaker extends StatelessWidget {
  final double height;
  final Widget header;
  final List<Widget> content;
  final Widget footer;
  final EdgeInsetsGeometry contentPadding;

  const DialogMaker({
    super.key,
    required this.header,
    required this.content,
    required this.footer,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 10),
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparent,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        // height: height,
        width: 350.0,
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          margin: EdgeInsets.zero,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: header,
              ),
              const Divider(),

              /// Content
              Flexible(
                child: Padding(
                  padding: contentPadding,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: content,
                  ),
                ),
              ),

              /// Footer
              const Divider(),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
