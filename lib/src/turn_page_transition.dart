import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

/// A widget that provides a page-turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    Key? key,
    required this.animation,
    required this.overleafColor,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
    required this.child,
  }) : super(key: key) {
    final transitionPoint = animationTransitionPoint ?? turningPoint;
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

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= turningPoint < 1).
  @Deprecated('Use animationTransitionPoint instead')
  final double? turningPoint;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// The widget that is displayed with the page-turning animation.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transitionPoint = this.animationTransitionPoint ??
        this.turningPoint ??
        defaultAnimationTransitionPoint;

    final alignment = direction == TurnDirection.rightToLeft
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
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
            widthFactor: animation.value,
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

    /// The horizontal distance of turned page top
    final turnedTopWidth = width;

    late final double topCornerX;
    late final double bottomCornerX;
    late final double foldUpperCornerX;
    switch (direction) {
      case TurnDirection.rightToLeft:
        topCornerX = turnedTopWidth;
        foldUpperCornerX = 0.0;
        bottomCornerX = turnedTopWidth;
        break;
      case TurnDirection.leftToRight:
        topCornerX = 0.0;
        foldUpperCornerX = turnedTopWidth;
        bottomCornerX = 0.0;
        break;
    }

    final topCorner = Offset(topCornerX, 0.0);
    final foldUpperCorner = Offset(foldUpperCornerX, 0.0);

    final path = Path()
      ..moveTo(topCorner.dx, topCorner.dy)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy);

    if (animationProgress <= animationTransitionPoint) {
      final bottomCornerY = height * verticalVelocity * animationProgress;
      final bottomCorner = Offset(bottomCornerX, bottomCornerY);
      path
        ..lineTo(bottomCorner.dx, bottomCorner.dy)
        ..close();
    } else {
      final widthCorrected = width / animationProgress;
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final turnedBottomWidth =
          widthCorrected * progressSubtractedDefault * horizontalVelocity;

      late final double foldLowerCornerX;
      switch (direction) {
        case TurnDirection.rightToLeft:
          foldLowerCornerX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          foldLowerCornerX = turnedBottomWidth;
          break;
      }

      final bottomCorner = Offset(bottomCornerX, height);
      final foldLowerCorner = Offset(foldLowerCornerX, height);

      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy) // BottomLeft
        ..lineTo(bottomCorner.dx, bottomCorner.dy) // BottomRight
        ..close();
    }

    return path;
  }

  /// Determines if the clipper should be updated based on the old clipper.
  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    print('reclip');
    return oldClipper.animation.value != animation.value;
  }
}

/// CustomPainter that paints the backside of the pages during the animation.
class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.animationTransitionPoint,
    required this.direction,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  final Color color;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// Paints the backside of the pages on the canvas based on the animation progress and direction.
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    late final double innerTopCornerX;
    late final double innerBottomCornerX;
    late final double foldUpperCornerX;
    late final double foldLowerCornerX;

    final verticalVelocity = 1 / animationTransitionPoint;
    final turnedXDistance = width * animationProgress;

    switch (direction) {
      case TurnDirection.rightToLeft:
        foldUpperCornerX = width - turnedXDistance;
        break;
      case TurnDirection.leftToRight:
        foldUpperCornerX = turnedXDistance;
        break;
    }
    final foldUpperCorner = Offset(foldUpperCornerX, 0.0);

    final path = Path()..moveTo(foldUpperCorner.dx, foldUpperCorner.dy);

    if (animationProgress <= animationTransitionPoint) {
      final turnedYDistance = height * animationProgress * verticalVelocity;

      final W = turnedXDistance;
      final H = turnedYDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      switch (direction) {
        case TurnDirection.rightToLeft:
          innerTopCornerX = width - 2 * intersectionX;
          foldLowerCornerX = width;
          break;
        case TurnDirection.leftToRight:
          innerTopCornerX = 2 * intersectionX;
          foldLowerCornerX = 0.0;
          break;
      }
      final innerTopCorner = Offset(innerTopCornerX, 2 * intersectionY);
      final foldLowerCorner = Offset(foldLowerCornerX, turnedYDistance);

      path
        ..lineTo(innerTopCorner.dx, innerTopCorner.dy)
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
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
          innerTopCornerX = width - 2 * intersectionX;
          innerBottomCornerX =
              width - 2 * intersectionX * intersectionCorrection;
          foldLowerCornerX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          innerTopCornerX = 2 * intersectionX;
          innerBottomCornerX = 2 * intersectionX * intersectionCorrection;
          foldLowerCornerX = turnedBottomWidth;
          break;
      }
      final innerTopCorner = Offset(innerTopCornerX, 2 * intersectionY);
      final innerBottomCorner = Offset(
        innerBottomCornerX,
        2 * intersectionY * intersectionCorrection + height,
      );
      final foldLowerCorner = Offset(foldLowerCornerX, height);

      path
        ..lineTo(innerTopCorner.dx, innerTopCorner.dy)
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy)
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
        ..close();
    } else {
      path.reset();
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, linePaint);
  }

  /// Determines if the painter should be repainted based on the old delegate.
  @override
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return oldPainter.animation.value != animation.value;
  }
}
