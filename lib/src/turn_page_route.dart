import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

/// A modal route that replaces the entire screen with Page-Turning transition.
/// you can use as [MaterialPageRoute].
///
/// example:
/// ElevatedButton(
///   onPressed: () => Navigator.of(context).push(
///     TurnPageRoute(
///       builder: (context) => const NextPage(),
///     ),
///   ),
///   child: const Text('go to next page'),
/// ),
class TurnPageRoute<T> extends PageRoute<T> {
  TurnPageRoute({
    RouteSettings? settings,
    required this.builder,
    this.overleafColor = defaultOverleafColor,
    this.turningPoint,
    this.direction = TurnDirection.rightToLeft,
    this.transitionDuration = defaultTransitionDuration,
    this.reverseTransitionDuration = defaultTransitionDuration,
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    bool fullscreenDialog = false,
  });

  final WidgetBuilder builder;

  /// The color of page backsides
  /// default Color is [Colors.grey]
  final Color overleafColor;

  final double? turningPoint;

  final TurnDirection direction;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
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
