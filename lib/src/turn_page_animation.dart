import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

/// A widget that provides a page-turning animation.
class TurnPageAnimation extends StatelessWidget {
  TurnPageAnimation({
    super.key,
    required this.animation,
    required this.overleafColor,
    required this.strokeColor,
    required this.strokeWidth,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
    required this.child,
  }) {
    final transitionPoint = animationTransitionPoint;
    assert(
      transitionPoint == null || 0 <= transitionPoint && transitionPoint < 1,
      'animationTransitionPoint must be 0 <= animationTransitionPoint < 1',
    );
  }

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  /// Default color is [Colors.grey].
  final Color overleafColor;

  final Color strokeColor;

  final double strokeWidth;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// The widget that is displayed with the page-turning animation.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transitionPoint =
        this.animationTransitionPoint ?? defaultAnimationTransitionPoint;

    final alignment = direction == TurnDirection.rightToLeft
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        animationTransitionPoint: transitionPoint,
        direction: direction,
      ),
      child: Align(
        alignment: alignment,
        child: ClipPath(
          clipper: _PageTurnClipper(
            animation: animation,
            animationTransitionPoint: transitionPoint,
            direction: direction,
          ),
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// CustomClipper that creates the page-turning clipping path.
class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({
    required this.animation,
    required this.animationTransitionPoint,
    this.direction = TurnDirection.leftToRight,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// Creates the clipping path based on the animation progress and direction.
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final verticalVelocity = 1 / animationTransitionPoint;

    late final double innerTopCornerX;
    late final double innerBottomCornerX;
    late final double outerBottomCornerX;
    late final double foldUpperCornerX;
    late final double foldLowerCornerX;
    switch (direction) {
      case TurnDirection.rightToLeft:
        innerTopCornerX = 0.0;
        innerBottomCornerX = 0.0;
        foldUpperCornerX = width * (1.0 - animationProgress);
        break;
      case TurnDirection.leftToRight:
        innerTopCornerX = width;
        innerBottomCornerX = width;
        foldUpperCornerX = width * animationProgress;
        break;
    }

    final innerTopCorner = Offset(innerTopCornerX, 0.0);
    final foldUpperCorner = Offset(foldUpperCornerX, 0.0);
    final innerBottomCorner = Offset(innerBottomCornerX, height);

    final path = Path()
      ..moveTo(innerTopCorner.dx, innerTopCorner.dy)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy);

    if (animationProgress <= animationTransitionPoint) {
      final foldLowerCornerY = height * verticalVelocity * animationProgress;
      switch (direction) {
        case TurnDirection.rightToLeft:
          outerBottomCornerX = width;
          foldLowerCornerX = width;
          break;
        case TurnDirection.leftToRight:
          outerBottomCornerX = 0.0;
          foldLowerCornerX = 0.0;
          break;
      }
      final outerBottomCorner = Offset(outerBottomCornerX, height);
      final foldLowerCorner = Offset(foldLowerCornerX, foldLowerCornerY);
      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
        ..lineTo(outerBottomCorner.dx, outerBottomCorner.dy)
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy)
        ..close();
    } else {
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final turnedBottomWidth =
          width * progressSubtractedDefault * horizontalVelocity;

      switch (direction) {
        case TurnDirection.rightToLeft:
          foldLowerCornerX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          foldLowerCornerX = turnedBottomWidth;
          break;
      }

      final foldLowerCorner = Offset(foldLowerCornerX, height);

      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy) // BottomLeft
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy) // BottomRight
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return true;
  }
}

/// CustomPainter that paints the backside of the pages during the animation.
class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
    required this.animationTransitionPoint,
    required this.direction,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  final Color color;

  final Color strokeColor;

  final double strokeWidth;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    late final double topCornerX;
    late final double bottomCornerX;
    late final double topFoldX;
    late final double bottomFoldX;

    final turnedXDistance = width * animationProgress;

    switch (direction) {
      case TurnDirection.rightToLeft:
        topFoldX = width - turnedXDistance;
        break;
      case TurnDirection.leftToRight:
        topFoldX = turnedXDistance;
        break;
    }
    final topFold = Offset(topFoldX, 0.0);

    final path = Path()..moveTo(topFold.dx, topFold.dy);

    if (animationProgress <= animationTransitionPoint) {
      final verticalVelocity = 1 / animationTransitionPoint;
      final turnedYDistance = height * animationProgress * verticalVelocity;

      final W = turnedXDistance;
      final H = turnedYDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      switch (direction) {
        case TurnDirection.rightToLeft:
          topCornerX = width - 2 * intersectionX;
          bottomFoldX = width;
          break;
        case TurnDirection.leftToRight:
          topCornerX = 2 * intersectionX;
          bottomFoldX = 0.0;
          break;
      }
      final topCorner = Offset(topCornerX, 2 * intersectionY);
      final bottomFold = Offset(bottomFoldX, turnedYDistance);

      path
        ..lineTo(topCorner.dx, topCorner.dy)
        ..lineTo(bottomFold.dx, bottomFold.dy)
        ..close();
    } else if (animationProgress < 1) {
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final turnedBottomWidthRate =
          horizontalVelocity * progressSubtractedDefault;

      // Alias that converts values to simple characters. -------
      final w2 = width * width;
      final h2 = height * height;
      final q = animationProgress - turnedBottomWidthRate;
      final q2 = q * q;

      // --------------------------------------------------------

      // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
      final intersectionX = width * h2 * animationProgress / (w2 * q2 + h2);
      final intersectionY =
          w2 * height * animationProgress * q / (w2 * q2 + h2);

      final intersectionCorrection =
          (animationProgress - q) / animationProgress;

      final turnedBottomWidth =
          width * progressSubtractedDefault * horizontalVelocity;

      switch (direction) {
        case TurnDirection.rightToLeft:
          topCornerX = width - 2 * intersectionX;
          bottomCornerX = width - 2 * intersectionX * intersectionCorrection;
          bottomFoldX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          topCornerX = 2 * intersectionX;
          bottomCornerX = 2 * intersectionX * intersectionCorrection;
          bottomFoldX = turnedBottomWidth;
          break;
      }
      final topCorner = Offset(topCornerX, 2 * intersectionY);
      final bottomCorner = Offset(
        bottomCornerX,
        2 * intersectionY * intersectionCorrection + height,
      );
      final bottomFold = Offset(bottomFoldX, height);

      path
        ..lineTo(topCorner.dx, topCorner.dy)
        ..lineTo(bottomCorner.dx, bottomCorner.dy)
        ..lineTo(bottomFold.dx, bottomFold.dy)
        ..close();
    } else {
      path.reset();
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return true;
  }
}
