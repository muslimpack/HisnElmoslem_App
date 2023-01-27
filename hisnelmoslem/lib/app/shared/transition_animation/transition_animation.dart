import 'package:flutter/material.dart';

import 'package:hisnelmoslem/app/shared/transition_animation/circle_clipper.dart';

TransitionAnimation transitionAnimation = TransitionAnimation();

class TransitionAnimation {
  fromBottom2Top({required BuildContext context, required Widget goToPage}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => goToPage,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void circleReval({required BuildContext context, required Widget goToPage}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => goToPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final screenSize = MediaQuery.of(context).size;
          // Offset center = Offset(screenSize.width - 40, screenSize.height - 40);
          final Offset center =
              Offset(screenSize.width / 2, screenSize.height / 2);
          const double beginRadius = 0.0;
          final double endRadius = screenSize.height * 1.2;

          final tween = Tween(begin: beginRadius, end: endRadius);
          final radiusTweenAnimation = animation.drive(tween);

          return ClipPath(
            clipper: CircleRevealClipper(
              radius: radiusTweenAnimation.value,
              center: center,
            ),
            child: child,
          );
        },
      ),
    );
  }

  void circleRevalPushReplacement({
    required BuildContext context,
    required Widget goToPage,
  }) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => goToPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final screenSize = MediaQuery.of(context).size;
          // Offset center = Offset(screenSize.width - 40, screenSize.height - 40);
          final Offset center =
              Offset(screenSize.width / 2, screenSize.height / 2);
          const double beginRadius = 0.0;
          final double endRadius = screenSize.height * 1.2;

          final tween = Tween(begin: beginRadius, end: endRadius);
          final radiusTweenAnimation = animation.drive(tween);

          return ClipPath(
            clipper: CircleRevealClipper(
              radius: radiusTweenAnimation.value,
              center: center,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
