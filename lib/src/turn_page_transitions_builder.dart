import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

class TurnPageTransitionsBuilder extends PageTransitionsBuilder {
  const TurnPageTransitionsBuilder({
    required this.overleafColor,
    this.turningPoint,
    this.direction = TurnDirection.rightToLeft,
  });

  final Color overleafColor;
  final double? turningPoint;
  final TurnDirection direction;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return TurnPageTransition(
      animation: animation,
      overleafColor: overleafColor,
      turningPoint: turningPoint,
      direction: direction,
      child: child,
    );
  }
}
