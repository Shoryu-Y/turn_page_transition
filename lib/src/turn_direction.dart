import 'package:turn_page_transition/src/turn_corner.dart';

/// The direction in which the pages are turned.
enum TurnDirection {
  rightToLeft,
  leftToRight;

  TurnCorner toTurnCorner() {
    switch (this) {
      case TurnDirection.rightToLeft:
        return TurnCorner.topRight;
      case TurnDirection.leftToRight:
        return TurnCorner.topLeft;
    }
  }
}
