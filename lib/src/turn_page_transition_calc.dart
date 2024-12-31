import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_corner.dart';

class PageTurnClipperCalculator {
  Offset calcCornerToFold({
    required double childWidth,
    required double childHeight,
    required TurnCorner turnCorner,
  }) {
    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = childWidth;
    } else {
      dx = 0;
    }
    if (turnCorner.isTop) {
      dy = 0;
    } else {
      dy = childHeight;
    }
    return Offset(dx, dy);
  }

  Offset calcOppositeCornerToFold({
    required double childWidth,
    required double childHeight,
    required TurnCorner turnCorner,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress > animationTransitionPoint) {
      late final double dx;
      late final double dy;
      if (turnCorner.isRight) {
        dx = childWidth;
      } else {
        dx = 0;
      }
      if (turnCorner.isTop) {
        dy = childHeight;
      } else {
        dy = 0;
      }
      return Offset(dx, dy);
    }

    // `animationProgress`の最大を`animationTransitionPoint`として、
    // めくられたページの高さの割合
    final turnedPageHeightRatio = animationProgress / animationTransitionPoint;

    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = childWidth;
    } else {
      dx = 0;
    }
    if (turnCorner.isTop) {
      dy = childHeight * turnedPageHeightRatio;
    } else {
      dy = childHeight - childHeight * turnedPageHeightRatio;
    }
    return Offset(dx, dy);
  }

  Offset calcFoldUpperCorner({
    required double childWidth,
    required double childHeight,
    required TurnCorner turnCorner,
  }) {
    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = 0;
    } else {
      dx = childWidth;
    }
    if (turnCorner.isTop) {
      dy = 0;
    } else {
      dy = childHeight;
    }
    return Offset(dx, dy);
  }

  Offset calcFoldLowerCorner({
    required double childWidth,
    required double screenWidth,
    required double screenHeight,
    required TurnCorner turnCorner,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      // animationProgressがanimationTransitionPointを超えない時、
      // foldLowerCornerはbottomCornerと一致する
      return calcOppositeCornerToFold(
        childWidth: childWidth,
        childHeight: screenHeight,
        turnCorner: turnCorner,
        animationTransitionPoint: animationTransitionPoint,
        animationProgress: animationProgress,
      );
    }

    final turnedPageBottomWidthRatio =
        (animationProgress - animationTransitionPoint) /
            (1 - animationTransitionPoint);
    final turnedPageBottomHorizontalDistance =
        screenWidth * turnedPageBottomWidthRatio;

    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = childWidth - turnedPageBottomHorizontalDistance;
    } else {
      dx = turnedPageBottomHorizontalDistance;
    }
    if (turnCorner.isTop) {
      dy = screenHeight;
    } else {
      dy = 0;
    }
    return Offset(dx, dy);
  }
}

class OverleafPainterCalculator {
  Offset calcCornerToFold({
    required double screenWidth,
    required double turnedHorizontalDistance,
    required double screenHeight,
    required TurnCorner turnCorner,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      final turnedPageHeightRatio =
          animationProgress / animationTransitionPoint;
      final turnedPageVerticalDistance = screenHeight * turnedPageHeightRatio;

      final W = turnedHorizontalDistance;
      final H = turnedPageVerticalDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      late final double dx;
      late final double dy;
      if (turnCorner.isRight) {
        dx = screenWidth - 2 * intersectionX;
      } else {
        dx = 2 * intersectionX;
      }
      if (turnCorner.isTop) {
        dy = 2 * intersectionY;
      } else {
        dy = screenHeight - 2 * intersectionY;
      }
      return Offset(dx, dy);
    } else {
      final turnedPageBottomWidthRatio =
          (animationProgress - animationTransitionPoint) /
              (1 - animationTransitionPoint);

      // Alias that converts values to simple characters. -------
      final w2 = screenWidth * screenWidth;
      final h2 = screenHeight * screenHeight;
      final q = animationProgress - turnedPageBottomWidthRatio;
      final q2 = q * q;
      // --------------------------------------------------------

      // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
      final intersectionX =
          screenWidth * h2 * animationProgress / (w2 * q2 + h2);
      final intersectionY =
          w2 * screenHeight * animationProgress * q / (w2 * q2 + h2);

      late final double dx;
      late final double dy;
      if (turnCorner.isRight) {
        dx = screenWidth - 2 * intersectionX;
      } else {
        dx = 2 * intersectionX;
      }
      if (turnCorner.isTop) {
        dy = 2 * intersectionY;
      } else {
        dy = screenHeight - 2 * intersectionY;
      }
      return Offset(dx, dy);
    }
  }

  Offset calcOppositeCornerToFold({
    required double screenWidth,
    required double screenHeight,
    required TurnCorner turnCorner,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      return calcFoldLowerCorner(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        turnCorner: turnCorner,
        animationTransitionPoint: animationTransitionPoint,
        animationProgress: animationProgress,
      );
    }

    final turnedPageBottomWidthRatio =
        (animationProgress - animationTransitionPoint) /
            (1 - animationTransitionPoint);

    // Alias that converts values to simple characters. -------
    final w2 = screenWidth * screenWidth;
    final h2 = screenHeight * screenHeight;
    final q = animationProgress - turnedPageBottomWidthRatio;
    final q2 = q * q;
    // --------------------------------------------------------

    // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
    final intersectionX = screenWidth * h2 * animationProgress / (w2 * q2 + h2);
    final intersectionY =
        w2 * screenHeight * animationProgress * q / (w2 * q2 + h2);

    final intersectionCorrection = (animationProgress - q) / animationProgress;

    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = screenWidth - 2 * intersectionX * intersectionCorrection;
    } else {
      dx = 2 * intersectionX * intersectionCorrection;
    }
    if (turnCorner.isTop) {
      dy = 2 * intersectionY * intersectionCorrection + screenHeight;
    } else {
      dy = 0;
    }
    return Offset(dx, dy);
  }

  Offset calcFoldUpperCorner({
    required double screenWidth,
    required double screenHeight,
    required double turnedHorizontalDistance,
    required TurnCorner turnCorner,
  }) {
    late final double dx;
    late final double dy;
    if (turnCorner.isRight) {
      dx = screenWidth - turnedHorizontalDistance;
    } else {
      dx = turnedHorizontalDistance;
    }
    if (turnCorner.isTop) {
      dy = 0;
    } else {
      dy = screenHeight;
    }
    return Offset(dx, dy);
  }

  Offset calcFoldLowerCorner({
    required double screenWidth,
    required double screenHeight,
    required TurnCorner turnCorner,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      final turnedPageHeightRatio =
          animationProgress / animationTransitionPoint;
      final turnedPageVerticalDistance = screenHeight * turnedPageHeightRatio;

      late final double dx;
      late final double dy;
      if (turnCorner.isRight) {
        dx = screenWidth;
      } else {
        dx = 0;
      }
      if (turnCorner.isTop) {
        dy = turnedPageVerticalDistance;
      } else {
        dy = screenHeight - turnedPageVerticalDistance;
      }
      return Offset(dx, dy);
    } else {
      final turnedPageBottomWidthRatio =
          (animationProgress - animationTransitionPoint) /
              (1 - animationTransitionPoint);

      final turnedBottomWidth = screenWidth * turnedPageBottomWidthRatio;

      late final double dx;
      late final double dy;
      if (turnCorner.isRight) {
        dx = screenWidth - turnedBottomWidth;
      } else {
        dx = turnedBottomWidth;
      }
      if (turnCorner.isTop) {
        dy = screenHeight;
      } else {
        dy = 0;
      }
      return Offset(dx, dy);
    }
  }
}
