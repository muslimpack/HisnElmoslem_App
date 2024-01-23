import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';

class FakehadithAppBar extends StatelessWidget {
  const FakehadithAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        S.of(context).fake_hadith,
      ),
      centerTitle: true,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      bottom: PreferredSize(
        preferredSize: const Size(0, 50),
        child: TabBar(
          indicatorColor: mainColor,
          tabs: [
            Tab(
              child: Text(
                S.of(context).new_,
                style: const TextStyle(
                  fontFamily: "Uthmanic",
                ),
              ),
            ),
            Tab(
              child: Text(
                S.of(context).have_been_read,
                style: const TextStyle(
                  fontFamily: "Uthmanic",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
