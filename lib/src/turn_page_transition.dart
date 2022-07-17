import 'package:flutter/material.dart';

/// The Widget to express Page-Turning animation.
class TurnPageTransition extends StatelessWidget {
  const TurnPageTransition({
    Key? key,
    required this.animation,
    required this.overleafColor,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;

  /// The color of page backsides
  /// default Color is [Colors.grey]
  final Color overleafColor;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ClipPath(
          clipper: _PageTurnClipper(animation: animation),
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
  const _PageTurnClipper({required this.animation});

  final Animation<double> animation;

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final progressTurningPoint = 0.1;
    final vVelocity = 1 / progressTurningPoint;

    final path = Path()
      ..moveTo(width, 0) // TopRight
      ..lineTo(0, 0); // TopLeft
    if (animationProgress <= progressTurningPoint) {
      final vDistanceRate = vVelocity * animationProgress;
      path
        ..lineTo(width, height * vDistanceRate) // BottomRightSide
        ..close();
    } else {
      final hCorrected = width / animationProgress;
      final progressSubtractedInitial = animationProgress - progressTurningPoint;
      final hVelocity = 1 / (1 - progressTurningPoint);
      final hTurnedDistance = hCorrected * progressSubtractedInitial * hVelocity;
      path
        ..lineTo(width - hTurnedDistance, height) // BottomLeft
        ..lineTo(width, height) // BottomRight
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
  });

  final Animation<double> animation;
  final Color color;

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

    final path = Path()..moveTo(width * (1 - animationProgress), 0);

    if (animationProgress <= 0.5) {
      final W = width * animationProgress;
      final H = height * animationProgress * 2;
      final x = width - 2 * (W * H * H) / (W * W + H * H);
      final y = 2 * (W * W * H) / (W * W + H * H);

      path
        ..lineTo(x, y) // ページの角
        ..lineTo(width, H) // ページの右端
        ..close();
    } else if (animationProgress < 1) {
      // alias value to simple letters;
      final w2 = width * width;
      final h2 = height * height;
      final mv = 1 - animationProgress;
      final mv2 = mv * mv;

      final x1 = width - 2 * width * h2 * animationProgress / (w2 * mv2 + h2);
      final y1 = 2 * w2 * height * animationProgress * mv / (w2 * mv2 + h2);

      final para2 = (2 * animationProgress - 1) / animationProgress;
      final x2 = width - 2 * width * h2 * animationProgress / (w2 * mv2 + h2) * para2;
      final y2 = y1 * para2 + height;

      path
        ..lineTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(width - width * 2 * (animationProgress - 0.5), height)
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
