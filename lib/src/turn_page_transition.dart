import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_corner.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_transition_calc.dart';

/// A widget that provides a page-turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    super.key,
    required this.animation,
    required this.overleafColor,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    @Deprecated("Use turnCorner instead")
    this.direction = TurnDirection.rightToLeft,
    TurnCorner? startCorner,
    required this.child,
  }) : startCorner = startCorner ?? direction.toTurnCorner() {
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

  @Deprecated("Use turnCorner instead")
  final TurnDirection direction;

  /// The corner where the turn should start
  final TurnCorner startCorner;

  /// The widget that is displayed with the page-turning animation.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transitionPoint = this.animationTransitionPoint ??
        this.turningPoint ??
        defaultAnimationTransitionPoint;

    final alignment =
        startCorner.isRight ? Alignment.centerRight : Alignment.centerLeft;

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
    // ここで取得しているsizeとは、画面全体のsizeではなく、childのAlignのsizeである。
    // AlignではwidthFactorに`animation.value`を設定しているため
    //   size.width = 画面全体のwidth * animation.value
    //   size.height = 画面全体のheight
    // で示される。
    // そのため画面全体のwidth(screenWidth)は size.width / animation.value で算出できる。
    final childWidth = size.width;
    final screenWidth = childWidth / animation.value;
    final screenHeight = size.height; // = childHeight = screenHeight

    // 上記で説明したように、sizeは既にめくられた遷移先画面のsizeであるため、
    // Pathに指定するOffsetもめくられた遷移先画面の左上が基準(Offset(0, 0))となる。
    final cornerToFold = calcCornerToFold(
      childWidth: childWidth,
      childHeight: screenHeight,
      turnCorner: startCorner,
    );
    final oppositeCornerToFold = calcOppositeCornerToFold(
      childWidth: childWidth,
      childHeight: screenHeight,
      turnCorner: startCorner,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final foldUpperCorner = calcFoldUpperCorner(
      childWidth: childWidth,
      childHeight: screenHeight,
      turnCorner: startCorner,
    );
    final foldLowerCorner = calcFoldLowerCorner(
      childWidth: childWidth,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      turnCorner: startCorner,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );

    final path = Path()
      ..moveTo(cornerToFold.dx, cornerToFold.dy)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy)
      ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
      ..lineTo(oppositeCornerToFold.dx, oppositeCornerToFold.dy)
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

  /// Paints the backside of the pages on the canvas based on the animation progress and direction.
  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value <= 0.0 || 1.0 <= animation.value) {
      return;
    }

    final screenWidth = size.width;
    final screenHeight = size.height;
    final turnedHorizontalDistance = screenWidth * animation.value;

    final foldUpperCorner = calcFoldUpperCorner(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      turnedHorizontalDistance: turnedHorizontalDistance,
      turnCorner: startCorner,
    );
    final cornerToFold = calcCornerToFold(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      turnedHorizontalDistance: turnedHorizontalDistance,
      turnCorner: startCorner,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final oppositeCorner = calcOppositeCornerToFold(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      turnCorner: startCorner,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );
    final foldLowerCorner = calcFoldLowerCorner(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      turnCorner: startCorner,
      animationTransitionPoint: animationTransitionPoint,
      animationProgress: animation.value,
    );

    final path = Path()
      ..moveTo(foldUpperCorner.dx, foldUpperCorner.dy)
      ..lineTo(cornerToFold.dx, cornerToFold.dy)
      ..lineTo(oppositeCorner.dx, oppositeCorner.dy)
      ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
      ..close();

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
