import 'package:flutter/material.dart';

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
    return Dialog(
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: 350.0,
        height: height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: header,
              ),
              const Divider(height: 0),

              /// Content
              Expanded(
                child: Center(
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
              ),

              /// Footer
              const Divider(height: 0),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
