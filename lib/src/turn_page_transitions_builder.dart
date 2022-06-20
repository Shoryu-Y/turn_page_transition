import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

class TurnPageTransitionsBuilder extends PageTransitionsBuilder {
  const TurnPageTransitionsBuilder({required this.overleafColor});

  final Color overleafColor;

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
      child: child,
    );
  }
}
