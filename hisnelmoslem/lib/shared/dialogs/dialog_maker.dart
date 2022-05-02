import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

class DialogMaker extends StatelessWidget {
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
        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparent,
      contentPadding: EdgeInsets.zero,
      content: Card(
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
            Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
            ),

            /// Footer
            const Divider(),
            footer,
          ],
        ),
      ),
    );
  }
}
