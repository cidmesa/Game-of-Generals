import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/helper/helper_methods.dart';

class Gameprovider extends ChangeNotifier {
  late List<List<GamePiece?>> board;

  List<List<int>> validMoves = [];

  GamePiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  int selectedPieceIndex = -1;

  bool initializing = true;
  bool? player1Initializing;
  bool? player2Initializing;
  bool? gameProper;

  // Initial Pieces
  void moveInitializationPiece(int row, int col) {}
  List<GamePiece> whitePieces = [
    // ✅ 1 of each piece
    GamePiece(type: GamePieceType.star5, isWhite: true, image: "5star.png"),
    GamePiece(type: GamePieceType.star4, isWhite: true, image: "4star.png"),
    GamePiece(type: GamePieceType.star3, isWhite: true, image: "3star.png"),
    GamePiece(type: GamePieceType.star2, isWhite: true, image: "2star.png"),
    GamePiece(type: GamePieceType.star1, isWhite: true, image: "1star.png"),
    GamePiece(type: GamePieceType.sun3, isWhite: true, image: "3sun.png"),
    GamePiece(type: GamePieceType.sun2, isWhite: true, image: "2sun.png"),
    GamePiece(type: GamePieceType.sun1, isWhite: true, image: "1sun.png"),
    GamePiece(
        type: GamePieceType.triangle3, isWhite: true, image: "3triangle.png"),
    GamePiece(
        type: GamePieceType.triangle2, isWhite: true, image: "2triangle.png"),
    GamePiece(
        type: GamePieceType.triangle1, isWhite: true, image: "1triangle.png"),
    GamePiece(
        type: GamePieceType.sergeant, isWhite: true, image: "sergeant.png"),
    GamePiece(type: GamePieceType.flag, isWhite: true, image: "flag.png"),

    // ✅ 6 Privates
    for (int i = 0; i < 6; i++)
      GamePiece(
          type: GamePieceType.private, isWhite: true, image: "private.png"),

    // ✅ 2 Spies
    for (int i = 0; i < 2; i++)
      GamePiece(type: GamePieceType.spy, isWhite: true, image: "spy.png"),
  ];

  void initializeBoard() {
    List<List<GamePiece?>> newBoard =
        List.generate(8, (index) => List.generate(9, (index) => null));

    //newBoard[7][0] =
    //GamePiece(type: GamePieceType.star5, isWhite: true, image: "5star.png");
    //newBoard[7][1] =
    //(type: GamePieceType.star5, isWhite: true, image: "5star.png");

    board = newBoard;
  }

  void pieceSelectedBoardInitialization(int row, int col) {
    if (board[row][col] != null) {
      selectedPiece = board[row][col];
      selectedPieceIndex = -1;
      selectedRow = row;
      selectedCol = col;
    } else if (selectedPieceIndex >= 0 &&
        selectedPieceIndex < whitePieces.length &&
        board[row][col] == null) {
      board[row][col] = whitePieces[selectedPieceIndex];
      whitePieces.removeAt(selectedPieceIndex);
      selectedPieceIndex = -1;
    } else if (selectedPiece != null && board[row][col] == null) {
      movePiece(row, col);
    }
    notifyListeners();
  }

  void pieceSelectedInitialize(index) {
    selectedPieceIndex = index;
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    notifyListeners();
  }

  void pieceSelected(int row, int col) {
    if (board[row][col] != null) {
      selectedPiece = board[row][col];
      selectedRow = row;
      selectedCol = col;
    } else if (selectedPiece != null &&
        validMoves.any((element) => element[0] == row && element[1] == col)) {
      movePiece(row, col);
    }
    validMoves = calculateMoves(selectedRow, selectedCol);
    notifyListeners();
  }

  void movePiece(int newRow, int newCol) {
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
    print(board);
  }

  List<List<int>> calculateMoves(int row, int col) {
    List<List<int>> candidateMoves = [];
    var moves = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    for (var move in moves) {
      var newRow = row + move[0];
      var newCol = col + move[1];

      if (!isInBoard(newRow, newCol)) {
        continue;
      }
      if (board[newRow][newCol] != null) {
        if (selectedPiece?.isWhite != board[newRow][newCol]!.isWhite) {
          candidateMoves.add([newRow, newCol]);
        }
        continue;
      }
      candidateMoves.add([newRow, newCol]);
    }
    return candidateMoves;
  }
}
