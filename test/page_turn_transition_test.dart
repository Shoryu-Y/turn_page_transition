import 'package:flutter_test/flutter_test.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

const screenWidth = 400.0;
const screenHeight = 800.0;

final animationTransitionPointCases = [0.3, 0.8];
final animationProgressCases = [0.3, 0.8];

void main() {
  final pCalculator = PageTurnClipperCalculator();
  final oCalculator = OverleafPainterCalculator();

  group('PageTurnClipperCalculator tests', () {
    TurnCorner.values.forEach((turnCorner) {
      animationTransitionPointCases.forEach((animationTransitionPoint) {
        animationProgressCases.forEach((animationProgress) {
          test(
              'Pattern:'
              'turnCorner: $turnCorner,'
              'animationTransitionPoint: $animationTransitionPoint,'
              'animationProgress: $animationProgress', () {
            final childWidth = screenWidth * animationProgress;

            final pFoldUpperCorner = pCalculator.calcFoldUpperCorner(
              childWidth: childWidth,
              childHeight: screenHeight,
              turnCorner: turnCorner,
            );
            final oFoldUpperCorner = oCalculator.calcFoldUpperCorner(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              turnedHorizontalDistance: childWidth,
              turnCorner: turnCorner,
            );

            final pFoldLowerCorner = pCalculator.calcFoldLowerCorner(
              childWidth: childWidth,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              turnCorner: turnCorner,
              animationTransitionPoint: animationTransitionPoint,
              animationProgress: animationProgress,
            );
            final oFoldLowerCorner = oCalculator.calcFoldLowerCorner(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              turnCorner: turnCorner,
              animationTransitionPoint: animationTransitionPoint,
              animationProgress: animationProgress,
            );

            if (turnCorner.isRight) {
              final fix = screenWidth - childWidth;
              expect(pFoldUpperCorner.dx + fix, oFoldUpperCorner.dx);
              expect(pFoldUpperCorner.dy, oFoldUpperCorner.dy);
              expect(pFoldLowerCorner.dx + fix, oFoldLowerCorner.dx);
              expect(pFoldLowerCorner.dy, oFoldLowerCorner.dy);
            } else {
              expect(pFoldUpperCorner, oFoldUpperCorner);
              expect(pFoldLowerCorner, oFoldLowerCorner);
            }
          });
        });
      });
    });
  });
}
