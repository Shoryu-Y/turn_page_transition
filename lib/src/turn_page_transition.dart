import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';

/// The Widget to express Page-Turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    Key? key,
    required this.animation,
    required this.overleafColor,
    this.turningPoint,
    required this.child,
  }) : super(key: key) {
    assert(
      turningPoint == null ||
          turningPoint != null && 0 <= turningPoint! && turningPoint! < 1,
      'turningPoint must be 0 <= turningPoint < 1',
    );
  }

  final Animation<double> animation;

  /// The color of page backsides
  /// default Color is [Colors.grey]
  final Color overleafColor;

  /// The point that behavior of the turn-page-animation changes.
  /// this value must be 0 <= turningPoint < 1
  final double? turningPoint;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final turningPoint = this.turningPoint ?? defaultTurningPoint;

    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
        turningPoint: turningPoint,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ClipPath(
          clipper: _PageTurnClipper(
            animation: animation,
            turningPoint: turningPoint,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: animation.value,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({required this.animation, required this.turningPoint});

  final Animation<double> animation;
  final double turningPoint;

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final vVelocity = 1 / turningPoint;

    /// The horizontal distance of turned page top
    final turnedTopWidth = width;

    final topRightX = turnedTopWidth;
    const topRightY = 0.0;
    const topLeftX = 0.0;
    const topLeftY = 0.0;
    final path = Path()
      ..moveTo(topRightX, topRightY)
      ..lineTo(topLeftX, topLeftY);

    if (animationProgress <= turningPoint) {
      final bottomX = turnedTopWidth;
      final bottomY = height * vVelocity * animationProgress;
      path
        ..lineTo(bottomX, bottomY)
        ..close();
    } else {
      final widthCorrected = width / animationProgress;
      final progressSubtractedDefault = animationProgress - turningPoint;
      final hVelocity = 1 / (1 - turningPoint);
      final turnedBottomWidth =
          widthCorrected * progressSubtractedDefault * hVelocity;

      final bottomLeftX = width - turnedBottomWidth;
      final bottomLeftY = height;
      final bottomRightX = width;
      final bottomRightY = height;
      path
        ..lineTo(bottomLeftX, bottomLeftY) // BottomLeft
        ..lineTo(bottomRightX, bottomRightY) // BottomRight
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.turningPoint,
  });

  final Animation<double> animation;
  final Color color;
  final double turningPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final turnedTopX = width * animationProgress;
    const turnedTopY = 0.0;
    final path = Path()..moveTo(width - turnedTopX, turnedTopY);

    if (animationProgress <= turningPoint) {
      final vVelocity = 1 / turningPoint;

      /// The horizontal distance of turned page
      final W = width * animationProgress;

      /// The vertical distance of turned page
      final H = height * animationProgress * vVelocity;

      /// Intersection of the line connecting (W, 0) & (W, H) and perpendicular line
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      /// Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H)
      final cornerX = width - 2 * intersectionX;
      final cornerY = 2 * intersectionY;
      final rightCreaseX = width;
      final rightCreaseY = H;

      path
        ..lineTo(cornerX, cornerY)
        ..lineTo(rightCreaseX, rightCreaseY)
        ..close();
    } else if (animationProgress < 1) {
      /// Alias that converts values to simple characters
      final w2 = width * width;
      final h2 = height * height;

      final hVelocity = 1 / (1 - turningPoint);
      final progressSubtractedDefault = animationProgress - turningPoint;
      final turnedBottomWidthRate = hVelocity * progressSubtractedDefault;

      final q = animationProgress - turnedBottomWidthRate;
      final q2 = q * q;

      /// Intersection of the line connecting (W, 0) & (W, H) and perpendicular line
      final intersectionX = width * h2 * animationProgress / (w2 * q2 + h2);
      final intersectionY =
          w2 * height * animationProgress * q / (w2 * q2 + h2);

      /// Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H)
      final topCornerX = width - 2 * intersectionX;
      final topCornerY = 2 * intersectionY;

      final intersectionCorrection =
          (animationProgress - q) / animationProgress;
      final bottomCornerX = width - 2 * intersectionX * intersectionCorrection;
      final bottomCornerY = 2 * intersectionY * intersectionCorrection + height;

      final turnedBottomWidth = width * progressSubtractedDefault * hVelocity;
      final bottomLeftX = width - turnedBottomWidth;
      final bottomLeftY = height;

      path
        ..lineTo(topCornerX, topCornerY)
        ..lineTo(bottomCornerX, bottomCornerY)
        ..lineTo(bottomLeftX, bottomLeftY)
        ..close();
    } else {
      path
        ..lineTo(0, 0)
        ..lineTo(0, height)
        ..lineTo(width * (1 - animationProgress), height)
        ..close();
    }

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
