import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

class TurnPageTransitionsBuilder extends PageTransitionsBuilder {
  const TurnPageTransitionsBuilder({
    required this.overleafColor,
    required this.strokeColor,
    required this.strokeWidth,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
  });

  final Color overleafColor;

  /// The color of the stroke line that appears on the page edge during transition
  final Color strokeColor;

  /// The width of the stroke line that appears on the page edge during transition
  final double strokeWidth;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= turningPoint < 1).
  @Deprecated('Use animationTransitionPoint instead')
  final double? turningPoint;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

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
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      animationTransitionPoint: transitionPoint,
      direction: direction,
      child: child,
    );
  }
}
