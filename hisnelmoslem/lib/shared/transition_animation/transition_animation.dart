import 'package:flutter/material.dart';

import 'circle_clipper.dart';

TransitionAnimation transitionAnimation = TransitionAnimation();

class TransitionAnimation {
  fromBottom2Top({required BuildContext context, required Widget goToPage}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => goToPage,
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  circleReval({required BuildContext context, required Widget goToPage}) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 1000),
      reverseTransitionDuration: Duration(milliseconds: 500),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) => goToPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var screenSize = MediaQuery.of(context).size;
        // Offset center = Offset(screenSize.width - 40, screenSize.height - 40);
        Offset center = Offset(screenSize.width / 2, screenSize.height / 2);
        double beginRadius = 0.0;
        double endRadius = screenSize.height * 1.2;

        var tween = Tween(begin: beginRadius, end: endRadius);
        var radiusTweenAnimation = animation.drive(tween);

        return ClipPath(
          clipper: CircleRevealClipper(
              radius: radiusTweenAnimation.value, center: center),
          child: child,
        );
      },
    ));
  }

  circleRevalPushReplacement(
      {required BuildContext context, required Widget goToPage}) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 1000),
      reverseTransitionDuration: Duration(milliseconds: 500),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) => goToPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var screenSize = MediaQuery.of(context).size;
        // Offset center = Offset(screenSize.width - 40, screenSize.height - 40);
        Offset center = Offset(screenSize.width / 2, screenSize.height / 2);
        double beginRadius = 0.0;
        double endRadius = screenSize.height * 1.2;

        var tween = Tween(begin: beginRadius, end: endRadius);
        var radiusTweenAnimation = animation.drive(tween);

        return ClipPath(
          clipper: CircleRevealClipper(
              radius: radiusTweenAnimation.value, center: center),
          child: child,
        );
      },
    ));
  }
}
