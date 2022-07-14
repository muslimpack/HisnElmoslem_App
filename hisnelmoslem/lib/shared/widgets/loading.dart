import 'package:flutter/material.dart';

import '../constants/constant.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
          mainColor,
        )),
      ),
    );
  }
}
