import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

/// The Widget to express Page-Turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    Key? key,
    required this.animation,
    required this.overleafColor,
    this.turningPoint,
    this.direction = TurnDirection.rightToLeft,
    required this.child,
  }) : super(key: key) {
    assert(
      turningPoint == null ||
          turningPoint != null && 0 <= turningPoint! && turningPoint! < 1,
      'turningPoint must be 0 <= turningPoint < 1',
    );
  }

  final Animation<double> animation;

  /// The color of page backsides.
  /// Default color is [Colors.grey]
  final Color overleafColor;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= turningPoint < 1.
  final double? turningPoint;

  /// Direction of page turnover.
  final TurnDirection direction;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final turningPoint = this.turningPoint ?? defaultTurningPoint;

    final alignment = direction == TurnDirection.rightToLeft
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
        turningPoint: turningPoint,
        direction: direction,
      ),
      child: Align(
        alignment: alignment,
        child: ClipPath(
          clipper: _PageTurnClipper(
            animation: animation,
            turningPoint: turningPoint,
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

class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({
    required this.animation,
    required this.turningPoint,
    this.direction = TurnDirection.leftToRight,
  });

  final Animation<double> animation;
  final double turningPoint;
  final TurnDirection direction;

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final verticalVelocity = 1 / turningPoint;

    /// The horizontal distance of turned page top
    final turnedTopWidth = width;

    late final double topCornerX;
    late final double bottomCornerX;
    late final double topFoldX;
    switch (direction) {
      case TurnDirection.rightToLeft:
        topCornerX = turnedTopWidth;
        topFoldX = 0.0;
        bottomCornerX = turnedTopWidth;
        break;
      case TurnDirection.leftToRight:
        topCornerX = 0.0;
        topFoldX = turnedTopWidth;
        bottomCornerX = 0.0;
        break;
    }

    final topCorner = Offset(topCornerX, 0.0);
    final topFold = Offset(topFoldX, 0.0);

    final path = Path()
      ..moveTo(topCorner.dx, topCorner.dy)
      ..lineTo(topFold.dx, topFold.dy);

    if (animationProgress <= turningPoint) {
      final bottomCornerY = height * verticalVelocity * animationProgress;
      final bottomCorner = Offset(bottomCornerX, bottomCornerY);
      path
        ..lineTo(bottomCorner.dx, bottomCorner.dy)
        ..close();
    } else {
      final widthCorrected = width / animationProgress;
      final progressSubtractedDefault = animationProgress - turningPoint;
      final horizontalVelocity = 1 / (1 - turningPoint);
      final turnedBottomWidth =
          widthCorrected * progressSubtractedDefault * horizontalVelocity;

      late final double bottomFoldX;
      switch (direction) {
        case TurnDirection.rightToLeft:
          bottomFoldX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          bottomFoldX = turnedBottomWidth;
          break;
      }

      final bottomCorner = Offset(bottomCornerX, height);
      final bottomFold = Offset(bottomFoldX, height);

      path
        ..lineTo(bottomFold.dx, bottomFold.dy) // BottomLeft
        ..lineTo(bottomCorner.dx, bottomCorner.dy) // BottomRight
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return false;
  }
}


class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.turningPoint,
    required this.direction,
  });

  final Animation<double> animation;
  final Color color;
  final double turningPoint;
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

    if (animationProgress <= turningPoint) {
      final verticalVelocity = 1 / turningPoint;
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
      final horizontalVelocity = 1 / (1 - turningPoint);
      final progressSubtractedDefault = animationProgress - turningPoint;
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
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
