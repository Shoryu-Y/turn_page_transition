import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition.dart';

/// A modal route that replaces the entire screen with a Page-Turning transition.
/// You can use it as a [MaterialPageRoute] replacement.
///
/// Example usage:
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
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
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

  /// The builder function to create the target widget.
  final WidgetBuilder builder;

  /// The color of the page backsides.
  /// Default color is [Colors.grey].
  final Color overleafColor;

  @Deprecated('Use animationTransitionPoint instead')
  final double? turningPoint;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
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
    final transitionPoint = animationTransitionPoint ?? turningPoint;

    return TurnPageTransition(
      animation: animation,
      overleafColor: overleafColor,
      animationTransitionPoint: transitionPoint,
      direction: direction,
      child: child,
    );
  }
}
