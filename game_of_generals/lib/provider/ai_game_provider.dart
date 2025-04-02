import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'dart:math';

class AIGameprovider extends ChangeNotifier {
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
  bool pendingWin = false;
  //bool isAIMode = true; // Flag to track AI mode

  // AI-related variables
  Random random = Random();

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
      GamePiece(type: GamePieceType.star5, isWhite: false, image: "5star.png"),
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
    deadPiecesArray = [];
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

      if (newRow == 0 && selectedPiece?.type == GamePieceType.flag) {
        final leftPiece = newCol > 0 ? board[newRow][newCol - 1] : null;
        final rightPiece =
            newCol < board[0].length - 1 ? board[newRow][newCol + 1] : null;

        if (leftPiece != null || rightPiece != null) {
          if ((leftPiece != null &&
                  leftPiece.isWhite != selectedPiece!.isWhite) ||
              (rightPiece != null &&
                  rightPiece.isWhite != selectedPiece!.isWhite)) {
            pendingWin = true;
          } else {
            gameWin = true;
          }
        } else {
          gameWin = true;
        }
      }
    }

    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
    isMoved = true;
  }

  void resetGame() {
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    selectedPieceIndex = -1;
    playerTurn = 2;

    initializing = true;
    whiteTurn = true;
    isReveal = true;
    isMoved = false;
    gameWin = false;
    pendingWin = false;
    validMoves = [];
    initializeBoard();
    notifyListeners();
  }

  List<List<int>> calculateMoves(int row, int col) {
    List<List<int>> candidateMoves = [];

    // Return empty list for invalid positions
    if (row < 0 || col < 0 || row >= board.length || col >= board[0].length) {
      return candidateMoves;
    }

    if (board[row][col] == null) {
      return candidateMoves;
    }

    var moves = [
      [1, 0], // down
      [-1, 0], // up
      [0, 1], // right
      [0, -1], // left
    ];

    for (var move in moves) {
      var newRow = row + move[0];
      var newCol = col + move[1];

      if (!isInBoard(newRow, newCol)) {
        continue;
      }
      if (board[newRow][newCol] != null) {
        if (board[row][col]!.isWhite != board[newRow][newCol]!.isWhite) {
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

        // In AI mode, automatically place black pieces after white finishes
        if (initializeArray.isNotEmpty) {
          placeAIPieces();
          // Skip black's turn completely
          initializing = false;
          isReveal = true;
          //flipBoard();
          notifyListeners();
          return;
        }
      } else {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
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

    if (pendingWin) {
      for (var piece in board[0]) {
        if (piece != null && piece.type == GamePieceType.flag) {
          gameWin = true;
          isReveal = true;
        }
      }
    }

    // Add AI move logic - when it becomes AI's turn
    if (!whiteTurn && !initializing) {
      // Add a small delay to make it feel more natural
      Future.delayed(Duration(milliseconds: 1000), () {
        if(!gameWin)
        {makeAIMove();} // Make the AI move
        Future.delayed(Duration(milliseconds: 1000), () {
          whiteTurn = !whiteTurn; // Switch back to player's turn
          reveal();
          playerTurn = 2;
          deadPiecesArray = whitePieces;
          flipBoard(); // Flip the board back// Hide the board again
          notifyListeners();
        });
      });
    }

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

  // Function to place AI pieces automatically
  void placeAIPieces() {
    // Shuffle pieces to randomize their order
    initializeArray.shuffle(random);

    // Create a 4x9 occupancy grid to track placed pieces
    List<List<bool>> occupiedCells =
        List.generate(3, (row) => List.generate(9, (col) => false));

    // Separate special and regular pieces
    GamePiece? flagPiece;
    List<GamePiece> highRankPieces = [];
    List<GamePiece> spies = [];
    List<GamePiece> regularPieces = [];

    for (var piece in initializeArray) {
      if (piece.type == GamePieceType.flag) {
        flagPiece = piece;
      } else if (piece.type == GamePieceType.star5 ||
          piece.type == GamePieceType.star4 ||
          piece.type == GamePieceType.star3) {
        highRankPieces.add(piece);
      } else if (piece.type == GamePieceType.spy) {
        spies.add(piece);
      } else {
        regularPieces.add(piece);
      }
    }

    // Flag placement: random but still towards the center
    List<int> potentialFlagCols = [2, 3, 4, 5, 6];
    potentialFlagCols.shuffle(random);
    int flagCol = potentialFlagCols.first;
    int flagRow = random.nextInt(2); // Prefer top two rows for flag

    if (flagPiece != null) {
      board[flagRow][flagCol] = flagPiece;
      occupiedCells[flagRow][flagCol] = true;
    }

    // Place high-ranking pieces around the flag for defense
    List<List<int>> protectionPositions = [
      [flagRow, flagCol - 1],
      [flagRow, flagCol + 1],
      [flagRow + 1, flagCol - 1],
      [flagRow + 1, flagCol],
      [flagRow + 1, flagCol + 1]
    ];
    protectionPositions.shuffle(random);

    int protectionPieceCount =
        min(highRankPieces.length, protectionPositions.length);
    for (int i = 0; i < protectionPieceCount; i++) {
      int row = protectionPositions[i][0];
      int col = protectionPositions[i][1];
      if (isInBoard(row, col) && !occupiedCells[row][col]) {
        board[row][col] = highRankPieces[i];
        occupiedCells[row][col] = true;
      }
    }
    highRankPieces = highRankPieces.sublist(protectionPieceCount);

    // Combine remaining pieces and shuffle
    List<GamePiece> remainingPieces = [
      ...highRankPieces,
      ...spies,
      ...regularPieces
    ];
    remainingPieces.shuffle(random);

    // Place remaining pieces randomly within 4 rows and 9 columns
    List<List<int>> availablePositions = [];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 9; col++) {
        if (!occupiedCells[row][col]) {
          availablePositions.add([row, col]);
        }
      }
    }

    availablePositions.shuffle(random);
    for (int i = 0;
        i < remainingPieces.length && i < availablePositions.length;
        i++) {
      int row = availablePositions[i][0];
      int col = availablePositions[i][1];
      board[row][col] = remainingPieces[i];
      occupiedCells[row][col] = true;
    }

    // Clear the initialize array after placement
    initializeArray = [];
  }

  // AI MOVE LOGIC
  void makeAIMove() {
    if (whiteTurn || gameWin) return; // Only make moves when it's AI's turn (black)

    // Create a list of potential moves for all AI pieces
    List<Map<String, dynamic>> allPossibleMoves = [];

    // Check each cell for AI pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 9; col++) {
        GamePiece? piece = board[row][col];

        // If the cell has an AI piece (black)
        if (piece != null && !piece.isWhite) {
          // Calculate valid moves for this piece
          List<List<int>> pieceMoves = calculateMoves(row, col);

          // Add each valid move to our list with evaluation data
          for (var move in pieceMoves) {
            int targetRow = move[0];
            int targetCol = move[1];
            double moveScore = evaluateMove(row, col, targetRow, targetCol);

            allPossibleMoves.add({
              'fromRow': row,
              'fromCol': col,
              'toRow': targetRow,
              'toCol': targetCol,
              'piece': piece,
              'score': moveScore,
            });
          }
        }
      }
    }

    // If we have valid moves
    if (allPossibleMoves.isNotEmpty) {
      // Sort moves by score (higher is better)
      allPossibleMoves.sort((a, b) => b['score'].compareTo(a['score']));

      // Add some randomness to avoid predictable behavior
      // Pick from top 3 moves (or fewer if we don't have 3)
      int choiceLimit =
          allPossibleMoves.length < 3 ? allPossibleMoves.length : 3;
      int selectedMoveIndex = random.nextInt(choiceLimit);
      var selectedMove = allPossibleMoves[selectedMoveIndex];

      // Execute the chosen move
      selectedPiece = board[selectedMove['fromRow']][selectedMove['fromCol']];
      selectedRow = selectedMove['fromRow'];
      selectedCol = selectedMove['fromCol'];
      movePiece(selectedMove['toRow'], selectedMove['toCol']);
    }

    notifyListeners();
  }

  // Evaluate how good a move is (higher score = better move)
  double evaluateMove(int fromRow, int fromCol, int toRow, int toCol) {
    double score = 0.0;
    GamePiece? movingPiece = board[fromRow][fromCol];
    GamePiece? targetPiece = board[toRow][toCol];

    // Base score - slightly favor forward movement (toward player's pieces)
    score += (fromRow - toRow) * 0.5;

    // If this is a capture move
    if (targetPiece != null) {
      // Flag capture is highest priority
      if (targetPiece.type == GamePieceType.flag) {
        return 1000.0; // Immediate win, highest priority
      }

      // Determine if we can win this battle
      bool canWin = false;
      bool drawLikely = false;

      // Check special cases first
      if (movingPiece!.type == GamePieceType.spy &&
          targetPiece.pieceScore == 1) {
        // Spy can't capture private
        canWin = false;
      } else if (movingPiece.pieceScore == 1 &&
          targetPiece.type == GamePieceType.spy) {
        // Private can capture spy
        canWin = true;
      } else if (movingPiece.pieceScore == targetPiece.pieceScore) {
        // Same rank results in both pieces removed
        drawLikely = true;
      } else {
        // Normal rank comparison
        canWin = movingPiece.pieceScore! > targetPiece.pieceScore!;
      }

      if (canWin) {
        // Prioritize capturing higher-value pieces
        score += 10.0 + targetPiece.pieceScore!;
      } else if (drawLikely) {
        // Consider draws based on piece value difference
        if (movingPiece.pieceScore! < targetPiece.pieceScore!) {
          // Trading up is good
          score += 5.0 + (targetPiece.pieceScore! - movingPiece.pieceScore!);
        } else {
          // Trading equal or down is less desirable but sometimes acceptable
          score += 2.0;
        }
      } else {
        // Avoid losing pieces
        score -= 20.0;
      }
    } else {
      // Non-capture move evaluation

      // Protect the flag - don't move it unless necessary
      if (movingPiece!.type == GamePieceType.flag) {
        score -= 15.0;
      }

      // Advance strong pieces toward enemy
      if (movingPiece.pieceScore! >= 10) {
        // High ranking officers
        score += 3.0;
      }

      // Advance spies selectively
      if (movingPiece.type == GamePieceType.spy) {
        score += 2.0;
      }

      // Consider proximity to enemy pieces
      int enemyPiecesNearby = countNearbyEnemies(toRow, toCol);
      if (movingPiece.pieceScore! > 5) {
        // Strong pieces can approach enemies
        score += enemyPiecesNearby * 1.0;
      } else {
        // Weaker pieces should be more cautious
        score -= enemyPiecesNearby * 0.5;
      }
    }

    // Add slight randomness to avoid predictable patterns
    score += random.nextDouble() * 2.0;

    return score;
  }

  // Count enemy pieces in adjacent squares
  int countNearbyEnemies(int row, int col) {
    int count = 0;
    var directions = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ];

    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

      if (isInBoard(newRow, newCol) &&
          board[newRow][newCol] != null &&
          board[newRow][newCol]!.isWhite) {
        count++;
      }
    }

    return count;
  }

  // Helper function to check if a position is valid on the board
  bool isInBoard(int row, int col) {
    return row >= 0 && col >= 0 && row < board.length && col < board[0].length;
  }
}
