import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_corner.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

/// A widget that provides a page-turning animation.
class TurnPageAnimation extends StatelessWidget {
  TurnPageAnimation({
    super.key,
    required this.animation,
    required this.overleafColor,
    this.animationTransitionPoint,
    @Deprecated("Use turnCorner instead")
    this.direction = TurnDirection.rightToLeft,
    TurnCorner? startCorner,
    required this.child,
  }) : startCorner = startCorner ?? direction.toTurnCorner() {
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

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  @Deprecated("Use [turnCorner] instead")
  final TurnDirection direction;

  /// The corner where the turn should start
  final TurnCorner startCorner;

  /// The widget that is displayed with the page-turning animation.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transitionPoint =
        this.animationTransitionPoint ?? defaultAnimationTransitionPoint;

    final alignment =
        startCorner.isRight ? Alignment.centerLeft : Alignment.centerRight;

    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
        animationTransitionPoint: transitionPoint,
        startCorner: startCorner,
      ),
      child: Align(
        alignment: alignment,
        child: ClipPath(
          clipper: _PageTurnClipper(
            animation: animation,
            animationTransitionPoint: transitionPoint,
            startCorner: startCorner,
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
    required this.startCorner,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The corner where the turn should start
  final TurnCorner startCorner;

  /// Creates the clipping path based on the animation progress and direction.
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final verticalVelocity = 1 / animationTransitionPoint;

    late final double innerTopCornerX;
    late final double innerTopCornerY;
    late final double innerBottomCornerX;
    late final double innerBottomCornerY;
    late final double outerBottomCornerX;
    late final double outerBottomCornerY;
    late final double foldUpperCornerX;
    late final double foldUpperCornerY;
    late final double foldLowerCornerX;
    late final double foldLowerCornerY;
    if (startCorner.isRight) {
      innerTopCornerX = 0.0;
      innerBottomCornerX = 0.0;
      foldUpperCornerX = width * (1.0 - animationProgress);
    } else {
      innerTopCornerX = width;
      innerBottomCornerX = width;
      foldUpperCornerX = width * animationProgress;
    }
    if (startCorner.isTop) {
      innerTopCornerY = 0;
      innerBottomCornerY = height;
      foldUpperCornerY = 0;
    } else {
      innerTopCornerY = height;
      innerBottomCornerY = 0;
      foldUpperCornerY = height;
    }

    final path = Path()
      ..moveTo(innerTopCornerX, innerTopCornerY)
      ..lineTo(foldUpperCornerX, foldUpperCornerY);

    if (animationProgress <= animationTransitionPoint) {
      if (startCorner.isRight) {
        outerBottomCornerX = width;
        foldLowerCornerX = width;
      } else {
        outerBottomCornerX = 0.0;
        foldLowerCornerX = 0.0;
      }
      if (startCorner.isTop) {
        foldLowerCornerY = height * verticalVelocity * animationProgress;
        outerBottomCornerY = height;
      } else {
        foldLowerCornerY = 0;
        outerBottomCornerY = 0;
      }
      path
        ..lineTo(foldLowerCornerX, foldLowerCornerY)
        ..lineTo(outerBottomCornerX, outerBottomCornerY)
        ..lineTo(innerBottomCornerX, innerBottomCornerY)
        ..close();
    } else {
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final turnedBottomWidth =
          width * progressSubtractedDefault * horizontalVelocity;

      if (startCorner.isRight) {
        foldLowerCornerX = width - turnedBottomWidth;
      } else {
        foldLowerCornerX = turnedBottomWidth;
      }
      if (startCorner.isTop) {
        foldLowerCornerY = height;
      } else {
        foldLowerCornerY = 0;
      }

      path
        ..lineTo(foldLowerCornerX, foldLowerCornerY) // BottomLeft
        ..lineTo(innerBottomCornerX, innerBottomCornerY) // BottomRight
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
    required this.animationTransitionPoint,
    required this.startCorner,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  final Color color;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The corner where the turn should start
  final TurnCorner startCorner;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    late final double startCornerX;
    late final double startCornerY;
    late final double endCornerX;
    late final double endCornerY;
    late final double topFoldX;
    late final double topFoldY;
    late final double bottomFoldX;
    late final double bottomFoldY;

    final turnedXDistance = width * animationProgress;

    if (startCorner.isRight) {
      topFoldX = width - turnedXDistance;
    } else {
      topFoldX = turnedXDistance;
    }
    if (startCorner.isTop) {
      topFoldY = 0;
    } else {
      topFoldY = height;
    }

    final path = Path()..moveTo(topFoldX, topFoldY);

    if (animationProgress <= animationTransitionPoint) {
      final verticalVelocity = 1 / animationTransitionPoint;
      final turnedYDistance = height * animationProgress * verticalVelocity;

      final W = turnedXDistance;
      final H = turnedYDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      if (startCorner.isRight) {
        startCornerX = width - 2 * intersectionX;
        bottomFoldX = width;
      } else {
        startCornerX = 2 * intersectionX;
        bottomFoldX = 0.0;
      }
      if (startCorner.isTop) {
        startCornerY = 2 * intersectionY;
        bottomFoldY = turnedYDistance;
      } else {
        startCornerY = height - 2 * intersectionY;
        bottomFoldY = 0;
      }

      path
        ..lineTo(startCornerX, startCornerY)
        ..lineTo(bottomFoldX, bottomFoldY)
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

      if (startCorner.isRight) {
        startCornerX = width - 2 * intersectionX;
        endCornerX = width - 2 * intersectionX * intersectionCorrection;
        bottomFoldX = width - turnedBottomWidth;
      } else {
        startCornerX = 2 * intersectionX;
        endCornerX = 2 * intersectionX * intersectionCorrection;
        bottomFoldX = turnedBottomWidth;
      }
      if (startCorner.isTop) {
        startCornerY = 2 * intersectionY;
        endCornerY = 2 * intersectionY * intersectionCorrection + height;
        bottomFoldY = height;
      } else {
        startCornerY = height - 2 * intersectionY;
        endCornerY = 0;
        bottomFoldY = 0;
      }

      path
        ..lineTo(startCornerX, startCornerY)
        ..lineTo(endCornerX, endCornerY)
        ..lineTo(bottomFoldX, bottomFoldY)
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
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return true;
  }
}
