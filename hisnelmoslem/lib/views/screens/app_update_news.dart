import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';

import '../../shared/constants/new_featuers_list.dart';

class AppUpdateNews extends StatelessWidget {
  const AppUpdateNews({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("جديد التحديثات"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ScrollGlowCustom(
        child: ListView.separated(
          itemCount: updateNewFeature.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                index == 0 ? Icons.upcoming : Icons.arrow_circle_up,
                color: index == 0 ? mainColor : null,
              ),
              title: Text(index == 0
                  ? "الإصدار الحالي: ${updateNewFeature[index][0]}"
                  : updateNewFeature[index][0]),
              subtitle: Text(updateNewFeature[index][1]),
              onTap: () {},
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ),
    );
  }
}
