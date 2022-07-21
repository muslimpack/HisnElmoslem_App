import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';

class DialogMaker extends StatelessWidget {
  final double height;
  final Widget header;
  final List<Widget> content;
  final Widget footer;
  final EdgeInsetsGeometry contentPadding;

  const DialogMaker({
    Key? key,
    required this.header,
    required this.content,
    required this.footer,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparent,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: height,
        width: 350.0,
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          margin: const EdgeInsets.all(0.0),
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
                  child: ScrollGlowRemover(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: content,
                    ),
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
