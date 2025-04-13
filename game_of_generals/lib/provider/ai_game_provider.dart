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

  // AI settings
  int _aiDifficulty = 3; // 1=easy, 2=medium, 3=hard
  Random random = Random();

  // Minimax depth settings based on difficulty
  Map<int, int> _difficultyDepth = {
    1: 1, // Easy: Look ahead 1 move
    2: 3, // Medium: Look ahead 3 moves
    3: 5, // Hard: Look ahead 5 moves
  };

  // Set AI difficulty
  void setAIDifficulty(int difficulty) {
    if (difficulty >= 1 && difficulty <= 3) {
      _aiDifficulty = difficulty;
    }
  }

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
        if (!gameWin) {
          makeAIMove();
        } // Make the AI move
        Future.delayed(Duration(milliseconds: 1000), () {
          whiteTurn = !whiteTurn;
          if (!gameWin) {
            // Switch back to player's turn
            reveal();
            playerTurn = 2;
            deadPiecesArray = whitePieces;
            flipBoard(); // Flip the board back
            notifyListeners();
          }
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

    // Create a 3x9 occupancy grid to track placed pieces
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
      if (isInBoard(row, col) && row < 3 && !occupiedCells[row][col]) {
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

    // Place remaining pieces randomly within 3 rows and 9 columns
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

  // MINIMAX AI IMPLEMENTATION
  void makeAIMove() {
    if (whiteTurn || gameWin)
      return; // Only make moves when it's AI's turn (black)

    // Get the minimax depth based on difficulty
    int depth = _difficultyDepth[_aiDifficulty] ?? 3;

    // Use a small depth for easy AI or add randomness
    if (_aiDifficulty == 1) {
      // Easy mode: 33% chance to make a random move instead of minimax
      if (random.nextDouble() < 0.33) {
        makeRandomMove();
        return;
      }
    }

    // Start minimax algorithm
    Move bestMove = findBestMove(depth);
    print("asdfafdsa");
    // Execute the best move
    if (bestMove.fromRow != -1) {
      selectedPiece = board[bestMove.fromRow][bestMove.fromCol];
      selectedRow = bestMove.fromRow;
      selectedCol = bestMove.fromCol;
      movePiece(bestMove.toRow, bestMove.toCol);
      notifyListeners();
    } else {
      // Fallback to random move if no good move found
      makeRandomMove();
    }
  }

  // Make a random legal move
  void makeRandomMove() {
    List<Move> allMoves =
        getAllPossibleMoves(false); // false = AI's turn (black)

    if (allMoves.isNotEmpty) {
      Move randomMove = allMoves[random.nextInt(allMoves.length)];
      selectedPiece = board[randomMove.fromRow][randomMove.fromCol];
      selectedRow = randomMove.fromRow;
      selectedCol = randomMove.fromCol;
      movePiece(randomMove.toRow, randomMove.toCol);
    }

    notifyListeners();
  }

  // Find the best move using minimax with alpha-beta pruning
  Move findBestMove(int depth) {
    Move bestMove = Move(-1, -1, -1, -1, -1000);
    double alpha = double.negativeInfinity;
    double beta = double.infinity;
    bool isMaximizingPlayer = false; // AI is minimizing (black)

    // Get all possible moves for the current player
    List<Move> possibleMoves = getAllPossibleMoves(isMaximizingPlayer);

    // If no moves available, return invalid move
    if (possibleMoves.isEmpty) {
      return bestMove;
    }

    // Shuffle moves to add variety to equally scored positions
    possibleMoves.shuffle(random);

    // Try each move and evaluate
    for (Move move in possibleMoves) {
      // Make the move
      GamePiece? capturedPiece = makeTemporaryMove(move);

      // Get score from minimax
      double score = minimax(depth - 1, alpha, beta, !isMaximizingPlayer);

      // Undo the move
      undoTemporaryMove(move, capturedPiece);

      // Update best move if better score found
      if (score < bestMove.score) {
        // AI is minimizing
        bestMove =
            Move(move.fromRow, move.fromCol, move.toRow, move.toCol, score);
      }

      // Update alpha
      beta = min(beta, score);

      // Alpha-beta pruning
      if (alpha >= beta) {
        break;
      }
    }

    // Add some randomness for lower difficulties
    if (_aiDifficulty < 3 && possibleMoves.length > 1) {
      // For Medium difficulty, 15% chance to not pick the absolute best move
      if (_aiDifficulty == 2 && random.nextDouble() < 0.15) {
        return possibleMoves[random.nextInt(possibleMoves.length)];
      }
    }

    return bestMove;
  }

  // Minimax algorithm with alpha-beta pruning
  double minimax(
      int depth, double alpha, double beta, bool isMaximizingPlayer) {
    // Terminal conditions
    if (gameWin) {
      return isMaximizingPlayer ? -1000 : 1000; // Win/loss scores
    }

    // Reached depth limit
    if (depth == 0) {
      return evaluateBoard();
    }

    List<Move> possibleMoves = getAllPossibleMoves(isMaximizingPlayer);

    // No valid moves - stalemate
    if (possibleMoves.isEmpty) {
      return 0;
    }

    if (isMaximizingPlayer) {
      double maxEval = double.negativeInfinity;

      for (Move move in possibleMoves) {
        GamePiece? capturedPiece = makeTemporaryMove(move);
        double eval = minimax(depth - 1, alpha, beta, false);
        undoTemporaryMove(move, capturedPiece);

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          break; // Beta cutoff
        }
      }

      return maxEval;
    } else {
      double minEval = double.infinity;

      for (Move move in possibleMoves) {
        GamePiece? capturedPiece = makeTemporaryMove(move);
        double eval = minimax(depth - 1, alpha, beta, true);
        undoTemporaryMove(move, capturedPiece);

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) {
          break; // Alpha cutoff
        }
      }

      return minEval;
    }
  }

  // Get all possible moves for the current player
  List<Move> getAllPossibleMoves(bool isWhitePlayer) {
    List<Move> moves = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 9; col++) {
        GamePiece? piece = board[row][col];

        // If cell has a piece of the current player
        if (piece != null && piece.isWhite == isWhitePlayer) {
          List<List<int>> validPositions = calculateMoves(row, col);

          for (var position in validPositions) {
            int newRow = position[0];
            int newCol = position[1];

            // Calculate move score using static evaluation
            double moveScore = evaluateMoveScore(row, col, newRow, newCol);
            moves.add(Move(row, col, newRow, newCol, moveScore));
          }
        }
      }
    }

    return moves;
  }

  // Make a temporary move for minimax evaluation
  GamePiece? makeTemporaryMove(Move move) {
    GamePiece? capturedPiece = board[move.toRow][move.toCol];
    GamePiece? movingPiece = board[move.fromRow][move.fromCol];

    if (capturedPiece != null) {
      // Handle piece capture according to game rules
      // (Simplified for minimax - just store the captured piece)
      board[move.toRow][move.toCol] = movingPiece;
      board[move.fromRow][move.fromCol] = null;
    } else {
      // Simple move
      board[move.toRow][move.toCol] = movingPiece;
      board[move.fromRow][move.fromCol] = null;
    }

    return capturedPiece;
  }

  // Undo a temporary move
  void undoTemporaryMove(Move move, GamePiece? capturedPiece) {
    GamePiece? movingPiece = board[move.toRow][move.toCol];

    // Restore the board state
    board[move.fromRow][move.fromCol] = movingPiece;
    board[move.toRow][move.toCol] = capturedPiece;
  }

  // Evaluate the current board state (static evaluation)
  double evaluateBoard() {
    double score = 0.0;

    // Material advantage
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 9; col++) {
        GamePiece? piece = board[row][col];
        if (piece != null) {
          // Piece value based on rank
          double pieceValue = pieceValueFactor(piece);

          // White pieces add to score, black pieces subtract
          if (piece.isWhite) {
            score += pieceValue;

            // Bonus for advancing flag
            if (piece.type == GamePieceType.flag) {
              score += (7 - row) * 2.0; // More points as flag moves forward
            }
          } else {
            score -= pieceValue;

            // Bonus for advancing flag
            if (piece.type == GamePieceType.flag) {
              score -= row * 2.0; // More points as flag moves forward
            }
          }

          // Mobility factor
          List<List<int>> pieceMoves = calculateMoves(row, col);
          double mobilityFactor = pieceMoves.length * 0.1;
          // Apply mobility factor to score
          if (piece.isWhite) {
            score += mobilityFactor;
          } else {
            score -= mobilityFactor;
          }

          // Position evaluation
          score += evaluatePosition(piece, row, col);
        }
      }
    }

    // Check for flag capture threats
    score += evaluateFlagSafety();

    return score;
  }

  // Helper method to determine piece value based on rank
  double pieceValueFactor(GamePiece piece) {
    switch (piece.type) {
      case GamePieceType.flag:
        return 100.0; // Flag is most valuable
      case GamePieceType.star5:
        return 15.0;
      case GamePieceType.star4:
        return 14.0;
      case GamePieceType.star3:
        return 13.0;
      case GamePieceType.star2:
        return 12.0;
      case GamePieceType.star1:
        return 11.0;
      case GamePieceType.sun3:
        return 10.0;
      case GamePieceType.sun2:
        return 9.0;
      case GamePieceType.sun1:
        return 8.0;
      case GamePieceType.triangle3:
        return 7.0;
      case GamePieceType.triangle2:
        return 6.0;
      case GamePieceType.triangle1:
        return 5.0;
      case GamePieceType.sergeant:
        return 4.0;
      case GamePieceType.private:
        return 2.0;
      case GamePieceType.spy:
        return 3.0;
      default:
        return 1.0;
    }
  }

  // Evaluate the position of a piece on the board
  double evaluatePosition(GamePiece piece, int row, int col) {
    double positionValue = 0.0;

    // Flag positioning - prefer back rank for safety
    if (piece.type == GamePieceType.flag) {
      if (piece.isWhite) {
        positionValue -= row * 0.5; // Penalize white flag moving forward
      } else {
        positionValue += (7 - row) * 0.5; // Penalize black flag moving forward
      }

      // Bonus for having the flag in a corner or edge (harder to capture)
      if (col == 0 || col == 8 || row == 0 || row == 7) {
        positionValue += 1.0;
      }
    }
    // High rank pieces positioning
    else if (piece.pieceScore! >= 11) {
      // Star ranks
      // Encourage high rank pieces to move forward for attack
      if (piece.isWhite) {
        positionValue += row * 0.2;
      } else {
        positionValue += (7 - row) * 0.2;
      }

      // Control center of board
      if (col >= 2 && col <= 6) {
        positionValue += 0.5;
      }
    }
    // Spy positioning
    else if (piece.type == GamePieceType.spy) {
      // Spies should advance to hunt privates
      if (piece.isWhite) {
        positionValue += row * 0.3;
      } else {
        positionValue += (7 - row) * 0.3;
      }
    }
    // Private positioning
    else if (piece.type == GamePieceType.private) {
      // Privates are useful for hunting spies or as flag shields
      if (col >= 2 && col <= 6) {
        positionValue += 0.3; // Useful in center
      }
    }

    return positionValue;
  }

  // Evaluate flag safety
  double evaluateFlagSafety() {
    double safetyScore = 0.0;

    // Find flags
    GamePiece? whiteFlag;
    GamePiece? blackFlag;
    int whiteFlagRow = -1;
    int whiteFlagCol = -1;
    int blackFlagRow = -1;
    int blackFlagCol = -1;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 9; col++) {
        GamePiece? piece = board[row][col];
        if (piece != null && piece.type == GamePieceType.flag) {
          if (piece.isWhite) {
            whiteFlag = piece;
            whiteFlagRow = row;
            whiteFlagCol = col;
          } else {
            blackFlag = piece;
            blackFlagRow = row;
            blackFlagCol = col;
          }
        }
      }
    }

    // If either flag is captured, return a large score
    if (whiteFlag == null) {
      return -1000.0; // White flag captured, bad for white
    }
    if (blackFlag == null) {
      return 1000.0; // Black flag captured, good for white
    }

    // Check for pieces protecting each flag
    if (whiteFlagRow != -1) {
      safetyScore += evaluateFlagProtection(whiteFlagRow, whiteFlagCol, true);
    }

    if (blackFlagRow != -1) {
      safetyScore -= evaluateFlagProtection(blackFlagRow, blackFlagCol, false);
    }

    return safetyScore;
  }

  // Helper method to evaluate flag protection
  double evaluateFlagProtection(int flagRow, int flagCol, bool isWhiteFlag) {
    double protectionScore = 0.0;
    List<List<int>> adjacentPositions = [
      [flagRow - 1, flagCol], // up
      [flagRow + 1, flagCol], // down
      [flagRow, flagCol - 1], // left
      [flagRow, flagCol + 1], // right
      [flagRow - 1, flagCol - 1], // up-left
      [flagRow - 1, flagCol + 1], // up-right
      [flagRow + 1, flagCol - 1], // down-left
      [flagRow + 1, flagCol + 1], // down-right
    ];

    // Count friendly pieces around the flag
    int friendlyPieces = 0;
    int enemyThreats = 0;

    for (var position in adjacentPositions) {
      int row = position[0];
      int col = position[1];

      if (isInBoard(row, col)) {
        GamePiece? piece = board[row][col];
        if (piece != null) {
          if (piece.isWhite == isWhiteFlag) {
            friendlyPieces++;
            // Higher value for higher rank protectors
            protectionScore += pieceValueFactor(piece) * 0.1;
          } else {
            enemyThreats++;
            // Direct threats are bad
            protectionScore -= pieceValueFactor(piece) * 0.2;
          }
        }
      }
    }

    // Strong protection bonus
    protectionScore += friendlyPieces * 2.0;

    // Heavy penalty for unprotected flags with nearby threats
    if (friendlyPieces == 0 && enemyThreats > 0) {
      protectionScore -= 10.0;
    }

    return protectionScore;
  }

  // Evaluate specific 1 score for move ordering
  double evaluateMoveScore(int fromRow, int fromCol, int toRow, int toCol) {
    double score = 0.0;
    GamePiece? movingPiece = board[fromRow][fromCol];
    GamePiece? targetPiece = board[toRow][toCol];

    if (movingPiece == null) return score;

    // Capture evaluation
    if (targetPiece != null) {
      // Basic capture score based on piece values
      double captureValue =
          pieceValueFactor(targetPiece) - pieceValueFactor(movingPiece) / 2;

      // Adjust for special cases

      // Flag capture is highest priority
      if (targetPiece.type == GamePieceType.flag) {
        return 1000.0;
      }

      // Spy capturing private case
      if (movingPiece.type == GamePieceType.spy &&
          targetPiece.type == GamePieceType.private) {
        captureValue -= 10.0; // Penalize this move as spy loses
      }

      // Private capturing spy case
      if (movingPiece.type == GamePieceType.private &&
          targetPiece.type == GamePieceType.spy) {
        captureValue += 5.0; // Bonus for this advantageous move
      }

      // Even trades slightly favor the AI at medium difficulty to encourage aggression
      if (movingPiece.pieceScore == targetPiece.pieceScore &&
          _aiDifficulty == 2) {
        captureValue += 0.5;
      }

      score += captureValue;
    } else {
      // Non-capture move evaluation

      // Flag movement evaluation
      if (movingPiece.type == GamePieceType.flag) {
        // Flag should generally avoid moving unless necessary
        score -= 5.0;

        // But if it's close to winning, encourage it
        if ((!movingPiece.isWhite && toRow == 0) ||
            (movingPiece.isWhite && toRow == 7)) {
          score += 50.0; // Big bonus for moves that can lead to winning
        }
      }

      // Forward movement bonus for attacking pieces
      if (movingPiece.isWhite) {
        score += (toRow - fromRow) * 0.3; // White moves down the board
      } else {
        score += (fromRow - toRow) * 0.3; // Black moves up the board
      }

      // Center control bonus
      if (toCol >= 2 && toCol <= 6) {
        score += 0.2;
      }
    }

    return score;
  }

  // Check if position is within board
  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 9;
  }
}

// Move class to store move information for minimax
class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final double score;

  Move(this.fromRow, this.fromCol, this.toRow, this.toCol, this.score);

  @override
  String toString() {
    return 'Move from ($fromRow,$fromCol) to ($toRow,$toCol) with score $score';
  }
}
