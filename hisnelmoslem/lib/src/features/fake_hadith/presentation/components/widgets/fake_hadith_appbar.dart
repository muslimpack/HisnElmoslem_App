import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

class FakehadithAppBar extends StatelessWidget {
  const FakehadithAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(S.of(context).fakeHadith),
      centerTitle: true,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: TabBar(
          tabs: [
            Tab(
              child: Text(
                S.of(context).newText,
              ),
            ),
            Tab(
              child: Text(
                S.of(context).haveBeenRead,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
