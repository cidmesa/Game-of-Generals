import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/helper/helper_methods.dart';

class Gameprovider extends ChangeNotifier {
  late List<List<GamePiece?>> board;

  List<List<int>> validMoves = [];

  List<GamePiece> whitePieces = [];

  List<GamePiece> blackPieces = [];

  List<GamePiece> initializeArray = [];

  List<GamePiece> deadPiecesArray = [];

  GamePiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  int selectedPieceIndex = -1;
  int playerTurn = 2;

  bool initializing = true;
  bool whiteTurn = true;
  bool isReveal = true;
  bool isMoved = false;
  bool gameWin = false;
  // Initial Pieces

  void initializeBoard() {
    List<List<GamePiece?>> newBoard =
        List.generate(8, (index) => List.generate(9, (index) => null));

    board = newBoard;

    whitePieces = [
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

    blackPieces = [
      GamePiece(type: GamePieceType.star4, isWhite: false, image: "4star.png"),
      GamePiece(type: GamePieceType.star3, isWhite: false, image: "3star.png"),
      GamePiece(type: GamePieceType.star2, isWhite: false, image: "2star.png"),
      GamePiece(type: GamePieceType.star1, isWhite: false, image: "1star.png"),
      GamePiece(type: GamePieceType.sun3, isWhite: false, image: "3sun.png"),
      GamePiece(type: GamePieceType.sun2, isWhite: false, image: "2sun.png"),
      GamePiece(type: GamePieceType.sun1, isWhite: false, image: "1sun.png"),
      GamePiece(
          type: GamePieceType.triangle3,
          isWhite: false,
          image: "3triangle.png"),
      GamePiece(
          type: GamePieceType.triangle2,
          isWhite: false,
          image: "2triangle.png"),
      GamePiece(
          type: GamePieceType.triangle1,
          isWhite: false,
          image: "1triangle.png"),
      GamePiece(
          type: GamePieceType.sergeant, isWhite: false, image: "sergeant.png"),
      GamePiece(type: GamePieceType.flag, isWhite: false, image: "flag.png"),

      // ✅ 6 Privates
      for (int i = 0; i < 6; i++)
        GamePiece(
            type: GamePieceType.private, isWhite: false, image: "private.png"),

      // ✅ 2 Spies
      for (int i = 0; i < 2; i++)
        GamePiece(type: GamePieceType.spy, isWhite: false, image: "spy.png"),
    ];
    initializeArray = whitePieces;
    whitePieces = [];
  }

  void pieceSelectedBoardInitialization(int row, int col) {
    if (board[row][col] != null && board[row][col]!.isWhite == whiteTurn) {
      selectedPiece = board[row][col];
      selectedPieceIndex = -1;
      selectedRow = row;
      selectedCol = col;  
    } else if (selectedPieceIndex >= 0 &&
        selectedPieceIndex < initializeArray.length &&
        board[row][col] == null &&
        row >= 5) {
      board[row][col] = initializeArray[selectedPieceIndex];
      initializeArray.removeAt(selectedPieceIndex);
      selectedPieceIndex = -1;
    } else if (selectedPiece != null && board[row][col] == null && row >= 5) {
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
    if (selectedPiece == null &&
        board[row][col] != null &&
        isReveal &&
        !isMoved) {
      if (board[row][col]!.isWhite == whiteTurn) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
    } else if (board[row][col] != null &&
        board[row][col]!.isWhite == selectedPiece!.isWhite) {
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
    // if take
    if (board[newRow][newCol] != null) {
      // if same rank
      if (board[selectedRow][selectedCol]!.pieceScore! ==
          board[newRow][newCol]!.pieceScore!) {
        if (board[selectedRow][selectedCol]!.type == GamePieceType.flag &&
            board[newRow][newCol]!.type == GamePieceType.flag) {
          gameWin = true;
          board[newRow][newCol] = selectedPiece;
          board[selectedRow][selectedCol] = null;
          return;
        }
        var capturedPiece = board[newRow][newCol];
        if (capturedPiece!.isWhite) {
          whitePieces.add(capturedPiece);
        } else {
          blackPieces.add(capturedPiece);
        }
        capturedPiece = board[selectedRow][selectedCol];
        if (capturedPiece!.isWhite) {
          whitePieces.add(capturedPiece);
        } else {
          blackPieces.add(capturedPiece);
        }
        board[newRow][newCol] = null;
        board[selectedRow][selectedCol] = null;
      }
      // if piece has higher rank
      else if (board[selectedRow][selectedCol]!.pieceScore! >
          board[newRow][newCol]!.pieceScore!) {
        // if spy captures private
        if (board[selectedRow][selectedCol]!.pieceScore! == 14 &&
            board[newRow][newCol]!.pieceScore! == 1) {
          var capturedPiece = board[selectedRow][selectedCol];
          if (capturedPiece!.isWhite) {
            whitePieces.add(capturedPiece);
          } else {
            blackPieces.add(capturedPiece);
          }
          board[selectedRow][selectedCol] = null;
        } else {
          var capturedPiece = board[newRow][newCol];
          if (capturedPiece!.type == GamePieceType.flag) {
            gameWin = true;
            board[newRow][newCol] = selectedPiece;
            board[selectedRow][selectedCol] = null;
            return;
          }

          if (capturedPiece.isWhite) {
            whitePieces.add(capturedPiece);
          } else {
            blackPieces.add(capturedPiece);
          }
          board[newRow][newCol] = selectedPiece;
          board[selectedRow][selectedCol] = null;
        }
      }
      // if lower rank
      else {
        // if Private takes spy
        if (board[selectedRow][selectedCol]!.pieceScore! == 1 &&
            board[newRow][newCol]!.pieceScore! == 14) {
          var capturedPiece = board[newRow][newCol];
          if (capturedPiece!.isWhite) {
            whitePieces.add(capturedPiece);
          } else {
            blackPieces.add(capturedPiece);
          }
          board[newRow][newCol] = selectedPiece;
          board[selectedRow][selectedCol] = null;
        } else {
          var capturedPiece = board[selectedRow][selectedCol];
          if (capturedPiece!.isWhite) {
            whitePieces.add(capturedPiece);
          } else {
            blackPieces.add(capturedPiece);
          }
          board[selectedRow][selectedCol] = null;
          if (capturedPiece.type == GamePieceType.flag) {
            gameWin = true;
            whiteTurn = !whiteTurn;
            return;
          }
        }
      }
    } else {
      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedCol] = null;
      if (newRow == 0 && selectedPiece!.type == GamePieceType.flag) {
        gameWin = true;

        return;
      }
    }

    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
    isMoved = true;
  }

  void resetGame() {
    selectedPiece;
    selectedRow = -1;
    selectedCol = -1;
    selectedPieceIndex = -1;
    playerTurn = 2;

    initializing = true;
    whiteTurn = true;
    isReveal = true;
    isMoved = false;
    gameWin = false;
    validMoves = [];
    initializeBoard();
    notifyListeners();
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

  void newTurn() {
    if (initializing) {
      if (whiteTurn) {
        selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
        initializeArray = blackPieces;
        blackPieces = [];
      } else {
        initializing = false;
        isReveal = false;
      }
    } else {
      isReveal = false;
    }

    whiteTurn = !whiteTurn;
    playerTurn = whiteTurn ? 2 : 1;
    if (whiteTurn) {
      deadPiecesArray = whitePieces;
    } else {
      deadPiecesArray = blackPieces;
    }

    flipBoard();
    notifyListeners();
  }

  void flipBoard() {
    List<List<GamePiece?>> flippedBoard = List.generate(
        8, (row) => List.generate(9, (col) => board[7 - row][8 - col]));

    board = flippedBoard;
  }

  void reveal() {
    isReveal = true;
    isMoved = false;
    notifyListeners();
  }
}
