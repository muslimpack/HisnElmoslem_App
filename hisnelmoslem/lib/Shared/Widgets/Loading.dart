import 'package:flutter/material.dart';

import '../constants/constant.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
          bleuShade200,
        )),
      ),
    );
  }
}
