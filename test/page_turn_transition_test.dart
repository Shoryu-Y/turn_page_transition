import 'package:flutter_test/flutter_test.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

const screenWidth = 400.0;
const screenHeight = 800.0;

final directionCases = [TurnDirection.rightToLeft, TurnDirection.leftToRight];
final animationTransitionPointCases = [0.3, 0.8];
final animationProgressCases = [0.3, 0.8];

void main() {
  final pCalculator = PageTurnClipperCalculator();
  final oCalculator = OverleafPainterCalculator();

  group('PageTurnClipperCalculator tests', () {
    directionCases.forEach((direction) {
      animationTransitionPointCases.forEach((animationTransitionPoint) {
        animationProgressCases.forEach((animationProgress) {
          test(
              'Pattern:'
              'direction: $direction,'
              'animationTransitionPoint: $animationTransitionPoint,'
              'animationProgress: $animationProgress', () {
            final childWidth = screenWidth * animationProgress;

            final pFoldUpperCorner = pCalculator.calcFoldUpperCorner(
              childWidth: childWidth,
              direction: direction,
            );
            final oFoldUpperCorner = oCalculator.calcFoldUpperCorner(
              screenWidth: screenWidth,
              turnedHorizontalDistance: childWidth,
              direction: direction,
            );

            final pFoldLowerCorner = pCalculator.calcFoldLowerCorner(
              childWidth: childWidth,
              screenWidth: screenWidth,
              height: screenHeight,
              direction: direction,
              animationTransitionPoint: animationTransitionPoint,
              animationProgress: animationProgress,
            );
            final oFoldLowerCorner = oCalculator.calcFoldLowerCorner(
              screenWidth: screenWidth,
              height: screenHeight,
              direction: direction,
              animationTransitionPoint: animationTransitionPoint,
              animationProgress: animationProgress,
            );

            switch (direction) {
              case TurnDirection.rightToLeft:
                final fix = screenWidth - childWidth;
                expect(pFoldUpperCorner.dx + fix, oFoldUpperCorner.dx);
                expect(pFoldUpperCorner.dy, oFoldUpperCorner.dy);
                expect(pFoldLowerCorner.dx + fix, oFoldLowerCorner.dx);
                expect(pFoldLowerCorner.dy, oFoldLowerCorner.dy);
                break;
              case TurnDirection.leftToRight:
                expect(pFoldUpperCorner, oFoldUpperCorner);
                expect(pFoldLowerCorner, oFoldLowerCorner);
                break;
            }
          });
        });
      });
    });
  });
}
