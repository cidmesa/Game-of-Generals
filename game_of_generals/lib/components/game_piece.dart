enum GamePieceType {
  star5,
  star4,
  star3,
  star2,
  star1,
  sun3,
  sun2,
  sun1,
  triangle3,
  triangle2,
  triangle1,
  sergeant,
  private,
  spy,
  flag
}

Map<GamePieceType, int> gamePieceScore = {
  GamePieceType.star5: 13,
  GamePieceType.star4: 12,
  GamePieceType.star3: 11,
  GamePieceType.star2: 10,
  GamePieceType.star1: 9,
  GamePieceType.sun3: 8,
  GamePieceType.sun2: 7,
  GamePieceType.sun1: 6,
  GamePieceType.triangle3: 5,
  GamePieceType.triangle2: 4,
  GamePieceType.triangle1: 3,
  GamePieceType.sergeant: 2,
  GamePieceType.private: 1,
};

class GamePiece {
  final GamePieceType type;
  final bool isWhite;
  String image;

  GamePiece({required this.type, required this.isWhite, required this.image}) {
    if (isWhite) {
      image = "lib/assets/White_$image";
    } else {
      image = "lib/assets/Black_$image";
    }
  }
}
