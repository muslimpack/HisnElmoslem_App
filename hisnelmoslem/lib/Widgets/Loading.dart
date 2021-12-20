import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue.shade200,
        )),
      ),
    );
  }
}
