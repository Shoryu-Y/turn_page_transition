import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/turn_direction.dart';

class PageTurnClipperCalculator {
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

    final turnedPageBottomWidthRatio =
        (animationProgress - animationTransitionPoint) /
            (1 - animationTransitionPoint);
    final turnedPageBottomHorizontalDistance =
        screenWidth * turnedPageBottomWidthRatio;

    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(childWidth - turnedPageBottomHorizontalDistance, height);
      case TurnDirection.leftToRight:
        return Offset(turnedPageBottomHorizontalDistance, height);
    }
  }
}

class OverleafPainterCalculator {
  Offset calcTopCorner({
    required double screenWidth,
    required double turnedHorizontalDistance,
    required double height,
    required TurnDirection direction,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      final turnedPageHeightRatio =
          animationProgress / animationTransitionPoint;
      final turnedPageVerticalDistance = height * turnedPageHeightRatio;

      final W = turnedHorizontalDistance;
      final H = turnedPageVerticalDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      switch (direction) {
        case TurnDirection.rightToLeft:
          return Offset(screenWidth - 2 * intersectionX, 2 * intersectionY);
        case TurnDirection.leftToRight:
          return Offset(2 * intersectionX, 2 * intersectionY);
      }
    } else {
      final turnedPageBottomWidthRatio =
          (animationProgress - animationTransitionPoint) /
              (1 - animationTransitionPoint);

      // Alias that converts values to simple characters. -------
      final w2 = screenWidth * screenWidth;
      final h2 = height * height;
      final q = animationProgress - turnedPageBottomWidthRatio;
      final q2 = q * q;
      // --------------------------------------------------------

      // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
      final intersectionX =
          screenWidth * h2 * animationProgress / (w2 * q2 + h2);
      final intersectionY =
          w2 * height * animationProgress * q / (w2 * q2 + h2);

      switch (direction) {
        case TurnDirection.rightToLeft:
          return Offset(screenWidth - 2 * intersectionX, 2 * intersectionY);
        case TurnDirection.leftToRight:
          return Offset(2 * intersectionX, 2 * intersectionY);
      }
    }
  }

  Offset calcBottomCorner({
    required double screenWidth,
    required double height,
    required TurnDirection direction,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      return calcFoldLowerCorner(
        screenWidth: screenWidth,
        height: height,
        direction: direction,
        animationTransitionPoint: animationTransitionPoint,
        animationProgress: animationProgress,
      );
    }

    final turnedPageBottomWidthRatio =
        (animationProgress - animationTransitionPoint) /
            (1 - animationTransitionPoint);

    // Alias that converts values to simple characters. -------
    final w2 = screenWidth * screenWidth;
    final h2 = height * height;
    final q = animationProgress - turnedPageBottomWidthRatio;
    final q2 = q * q;
    // --------------------------------------------------------

    // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
    final intersectionX = screenWidth * h2 * animationProgress / (w2 * q2 + h2);
    final intersectionY = w2 * height * animationProgress * q / (w2 * q2 + h2);

    final intersectionCorrection = (animationProgress - q) / animationProgress;

    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(
          screenWidth - 2 * intersectionX * intersectionCorrection,
          2 * intersectionY * intersectionCorrection + height,
        );
      case TurnDirection.leftToRight:
        return Offset(
          2 * intersectionX * intersectionCorrection,
          2 * intersectionY * intersectionCorrection + height,
        );
    }
  }

  Offset calcFoldUpperCorner({
    required double screenWidth,
    required double turnedHorizontalDistance,
    required TurnDirection direction,
  }) {
    switch (direction) {
      case TurnDirection.rightToLeft:
        return Offset(screenWidth - turnedHorizontalDistance, 0.0);
      case TurnDirection.leftToRight:
        return Offset(turnedHorizontalDistance, 0.0);
    }
  }

  Offset calcFoldLowerCorner({
    required double screenWidth,
    required double height,
    required TurnDirection direction,
    required double animationTransitionPoint,
    required double animationProgress,
  }) {
    if (animationProgress <= animationTransitionPoint) {
      final turnedPageHeightRatio =
          animationProgress / animationTransitionPoint;
      final turnedPageVerticalDistance = height * turnedPageHeightRatio;

      switch (direction) {
        case TurnDirection.rightToLeft:
          return Offset(screenWidth, turnedPageVerticalDistance);
        case TurnDirection.leftToRight:
          return Offset(0.0, turnedPageVerticalDistance);
      }
    } else {
      final turnedPageBottomWidthRatio =
          (animationProgress - animationTransitionPoint) /
              (1 - animationTransitionPoint);

      final turnedBottomWidth = screenWidth * turnedPageBottomWidthRatio;

      switch (direction) {
        case TurnDirection.rightToLeft:
          return Offset(screenWidth - turnedBottomWidth, height);
        case TurnDirection.leftToRight:
          return Offset(turnedBottomWidth, height);
      }
    }
  }
}
