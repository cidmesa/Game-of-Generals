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
