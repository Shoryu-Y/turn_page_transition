import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

/// A widget that provides a page-turning animation.
class TurnPageTransition extends StatelessWidget {
  TurnPageTransition({
    super.key,
    required this.animation,
    required this.overleafColor,
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

  /// 遷移後の画面の上側の角
  Offset calcTopCorner({
    required double childWidth,
    required TurnDirection direction,
  }) {
    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(childWidth, 0);
      case TurnDirection.leftToRight:
        return Offset(0, 0);
    }
  }

  /// 遷移後の画面の下側の角
  Offset calcBottomCorner({
    required double childWidth,
    required double height,
    required TurnDirection direction,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress > animationTransitionPoint) {
      switch (direction) {
        case TurnDirection.rightToLeft:
          return Offset(childWidth, height);
        case TurnDirection.leftToRight:
          return Offset(0, height);
      }
    }

    // `animationProgress`の最大を`animationTransitionPoint`として、
    // めくられたページの高さの割合
    final turnedPageHeightRatio = animationProgress / animationTransitionPoint;
    final bottomCornerY = height * turnedPageHeightRatio;

    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(childWidth, bottomCornerY);
      case TurnDirection.leftToRight:
        return Offset(0, bottomCornerY);
    }
  }

  Offset calcFoldUpperCorner({
    required double childWidth,
    required TurnDirection direction,
  }) {
    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(0, 0);
      case TurnDirection.leftToRight:
        return Offset(childWidth, 0);
    }
  }

  Offset calcFoldLowerCorner({
    required double childWidth,
    required double screenWidth,
    required double height,
    required TurnDirection direction,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      // animationProgressがanimationTransitionPointを超えない時、
      // foldLowerCornerはbottomCornerと一致する
      return calcBottomCorner(
        childWidth: childWidth,
        height: height,
        direction: direction,
        animationTransitionPoint: animationTransitionPoint,
        animationProgress: animationProgress,
      );
    }

    final turnedPageBottomProgress =
        animationProgress - animationTransitionPoint;
    final turnedPageBottomWidthRatio =
        turnedPageBottomProgress / (1 - animationTransitionPoint);
    final turnedBottomWidth = screenWidth * turnedPageBottomWidthRatio;

    switch (direction) {
      case TurnDirection.rightToLeft:
        final foldLowerCornerX = childWidth - turnedBottomWidth;
        return Offset(foldLowerCornerX, height);
      case TurnDirection.leftToRight:
        final foldLowerCornerX = turnedBottomWidth;
        return Offset(foldLowerCornerX, height);
    }
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
