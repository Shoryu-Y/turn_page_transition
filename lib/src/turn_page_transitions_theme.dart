import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_corner.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transitions_builder.dart';

/// A Theme of transition animation.
/// When you want to unify transitions on all screens,
/// you can easily do so
/// by setting [TurnPageTransitionsTheme] to [pageTransitionsTheme] argument of [ThemeData].
///
/// example:
///  return MaterialApp(
///       title: 'TurnPageTransition Example',
///       theme: ThemeData(
///         pageTransitionsTheme: const TurnPageTransitionsTheme(),
///         primarySwatch: Colors.blue,
///       ),
///       home: HomePage(),
///  )
class TurnPageTransitionsTheme extends PageTransitionsTheme {
  TurnPageTransitionsTheme({
    this.overleafColor = defaultOverleafColor,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    @Deprecated("Use turnCorner instead")
    this.direction = TurnDirection.rightToLeft,
    TurnCorner? startCorner,
  }) : startCorner = startCorner ?? direction.toTurnCorner();

  /// The color of page backsides
  /// default Color is [Colors.grey]
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

  PageTransitionsBuilder get _builder => TurnPageTransitionsBuilder(
        overleafColor: overleafColor,
        animationTransitionPoint: animationTransitionPoint ?? turningPoint,
        startCorner: startCorner,
      );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _builder.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
