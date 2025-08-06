import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition_calc.dart';

/// A widget that provides a page-turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    super.key,
    required this.animation,
    required this.overleafColor,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
    required this.child,
  }) {
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

  final Color strokeColor;
  final double strokeWidth;

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
            widthFactor: animation.value,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// CustomClipper that creates the page-turning clipping path.
class _PageTurnClipper extends CustomClipper<Path>
    with PageTurnClipperCalculator {
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
    // ここで取得しているsizeとは、画面全体のsizeではなく、childのAlignのsizeである。
    // AlignではwidthFactorに`animation.value`を設定しているため
    //   size.width = 画面全体のwidth * animation.value
    //   size.height = 画面全体のheight
    // で示される。
    // そのため画面全体のwidth(screenWidth)は size.width / animation.value で算出できる。
    final childWidth = size.width;
    final screenWidth = childWidth / animation.value;
    final height = size.height; // = childHeight = screenHeight

    // 上記で説明したように、sizeは既にめくられた遷移先画面のsizeであるため、
    // Pathに指定するOffsetもめくられた遷移先画面の左上が基準(Offset(0, 0))となる。
    final topCorner = calcTopCorner(
      childWidth: childWidth,
      direction: direction,
    );
    final bottomCorner = calcBottomCorner(
      childWidth: childWidth,
      height: height,
      direction: direction,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final foldUpperCorner = calcFoldUpperCorner(
      childWidth: childWidth,
      direction: direction,
    );
    final foldLowerCorner = calcFoldLowerCorner(
      childWidth: childWidth,
      screenWidth: screenWidth,
      height: height,
      direction: direction,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );

    final path = Path()
      ..moveTo(topCorner.dx, topCorner.dy)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy)
      ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
      ..lineTo(bottomCorner.dx, bottomCorner.dy)
      ..close();

    return path;
  }

  /// Determines if the clipper should be updated based on the old clipper.
  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return oldClipper.animation.value != animation.value;
  }
}

/// CustomPainter that paints the backside of the pages during the animation.
class _OverleafPainter extends CustomPainter with OverleafPainterCalculator {
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

  /// Paints the backside of the pages on the canvas based on the animation progress and direction.
  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value <= 0.0 || 1.0 <= animation.value) {
      return;
    }

    final screenWidth = size.width;
    final turnedHorizontalDistance = screenWidth * animation.value;
    final height = size.height;

    final foldUpperCorner = calcFoldUpperCorner(
      screenWidth: screenWidth,
      turnedHorizontalDistance: turnedHorizontalDistance,
      direction: direction,
    );
    final topCorner = calcTopCorner(
      screenWidth: screenWidth,
      turnedHorizontalDistance: turnedHorizontalDistance,
      height: height,
      direction: direction,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final bottomCorner = calcBottomCorner(
      screenWidth: screenWidth,
      height: height,
      direction: direction,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final foldLowerCorner = calcFoldLowerCorner(
      screenWidth: screenWidth,
      height: height,
      direction: direction,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );

    final path = Path()
      ..moveTo(foldUpperCorner.dx, foldUpperCorner.dy)
      ..lineTo(topCorner.dx, topCorner.dy)
      ..lineTo(bottomCorner.dx, bottomCorner.dy)
      ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
      ..close();

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

  /// Determines if the painter should be repainted based on the old delegate.
  @override
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return oldPainter.animation.value != animation.value;
  }
}
