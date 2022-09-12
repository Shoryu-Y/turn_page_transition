import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
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
  const TurnPageTransitionsTheme({
    this.overleafColor = defaultOverleafColor,
    this.turningPoint,
    this.direction = TurnDirection.rightToLeft,
  });

  /// The color of page backsides
  /// default Color is [Colors.grey]
  final Color overleafColor;

  final double? turningPoint;

  final TurnDirection direction;

  PageTransitionsBuilder get _builder => TurnPageTransitionsBuilder(
        overleafColor: overleafColor,
        turningPoint: turningPoint,
        direction: direction,
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
