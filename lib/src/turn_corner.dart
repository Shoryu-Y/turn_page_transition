/// The corner to turn.
enum TurnCorner {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft;

  /// Returns true if this corner is at the right of the screen
  get isRight => this == TurnCorner.bottomRight || this == TurnCorner.topRight;

  /// Returns true if this corner is at the top of the screen
  get isTop => this == TurnCorner.topLeft || this == TurnCorner.topRight;
}
