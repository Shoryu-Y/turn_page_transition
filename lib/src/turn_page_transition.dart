import 'package:flutter/material.dart';

class TurnPageTransition extends StatelessWidget {
  const TurnPageTransition({
    super.key,
    required this.animation,
    required this.color,
    required this.child,
  });

  final Animation<double> animation;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _LiningPainter(
        animation: animation,
        color: color,
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
    final value = animation.value;

    final path = Path()
      ..moveTo(width, 0)
      ..lineTo(0, 0);
    if (value <= 0.5) {
      final heightValue = value * 2;
      path
        ..lineTo(width, height * heightValue)
        ..close();
    } else {
      path
        ..lineTo(width - width / value * (value - 0.5) * 2, height)
        ..lineTo(width, height)
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _LiningPainter extends CustomPainter {
  const _LiningPainter({
    required this.animation,
    required this.color,
  });

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final value = animation.value;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()..moveTo(width * (1 - value), 0);

    if (value <= 0.5) {
      final W = width * value;
      final H = height * value * 2;
      final x = width - 2 * (W * H * H) / (W * W + H * H);
      final y = 2 * (W * W * H) / (W * W + H * H);

      path
        ..lineTo(x, y) // ページの角
        ..lineTo(width, H) // ページの右端
        ..close();
    } else if (value < 1) {
      // alias value to simple letters;
      final w2 = width * width;
      final h2 = height * height;
      final mv = 1 - value;
      final mv2 = mv * mv;

      final x1 = width - 2 * width * h2 * value / (w2 * mv2 + h2);
      final y1 = 2 * w2 * height * value * mv / (w2 * mv2 + h2);

      final para2 = (2 * value - 1) / value;
      final x2 = width - 2 * width * h2 * value / (w2 * mv2 + h2) * para2;
      final y2 = y1 * para2 + height;

      path
        ..lineTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(width - width * 2 * (value - 0.5), height)
        ..close();
    } else {
      path
        ..lineTo(0, 0)
        ..lineTo(0, height)
        ..lineTo(width * (1 - value), height)
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
