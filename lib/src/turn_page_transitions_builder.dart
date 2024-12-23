import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_corner.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

class TurnPageTransitionsBuilder extends PageTransitionsBuilder {
  TurnPageTransitionsBuilder({
    required this.overleafColor,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    @Deprecated("Use turnCorner instead")
    this.direction = TurnDirection.rightToLeft,
    TurnCorner? startCorner,
  }) : startCorner = startCorner ?? direction.toTurnCorner();

  final Color overleafColor;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= turningPoint < 1).
  @Deprecated('Use animationTransitionPoint instead')
  final double? turningPoint;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  @Deprecated("Use turnCorner instead")
  final TurnDirection direction;

  /// The corner where the turn should start
  final TurnCorner startCorner;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final transitionPoint = animationTransitionPoint ?? turningPoint;

    return TurnPageTransition(
      animation: animation,
      overleafColor: overleafColor,
      animationTransitionPoint: transitionPoint,
      startCorner: startCorner,
      child: child,
    );
  }
}
