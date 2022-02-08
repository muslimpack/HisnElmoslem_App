import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

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
        title: Text("جديد التحديثات"),
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: black26,
          child: ListView.separated(
            itemCount: updateNewFeature.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  Icons.arrow_circle_up,
                  color: index == 0 ? MAINCOLOR : white,
                ),
                title: Text(index == 0
                    ? "الإصدار الحالي: " + updateNewFeature[index][0]
                    : updateNewFeature[index][0]),
                subtitle: Text(updateNewFeature[index][1]),
                onTap: () {},
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        ),
      ),
    );
  }
}
