import 'package:flutter/material.dart';
import 'package:game_of_generals/components/center_button.dart';
import 'package:game_of_generals/components/draggable_initialization_square.dart';
import 'package:game_of_generals/provider/GameProvider.dart';
import 'package:provider/provider.dart';
import 'package:game_of_generals/components/draggable_board_square.dart';
import 'package:game_of_generals/components/game_piece.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Gameprovider(),
        )
      ],
      child: const MaterialApp(
        home: GameBoard(),
      ),
    ),
  );
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late GamePiece whiteGeneral5;
  late GamePiece whiteGeneral4;

  bool isGeneral5Used = false;
  bool isGeneral4Used = false;

  // 👇 Variable to store the grid size
  double? firstGridSize;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<Gameprovider>(context, listen: false).initializeBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Gameprovider>(builder: (context, gameProvider, child) {
      if (gameProvider.gameWin) {
        Future.microtask(() => showDialog(
              context: context,
              builder: (
                context,
              ) =>
                  AlertDialog(
                title: gameProvider.whiteTurn
                    ? Text("Player 1 win!")
                    : Text("Player 2 win!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      gameProvider.resetGame(); // Reset game
                    },
                    child: const Text("Reset Game"),
                  )
                ],
              ),
            ));
      }
      return Scaffold(
        appBar: AppBar(
          title:
              Text("Game of Generals", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double screenHeight = constraints.maxHeight;

                  // ✅ Store the grid size in the variable
                  firstGridSize = screenWidth < screenHeight
                      ? screenWidth * 0.95
                      : screenHeight * 0.95;

                  return Center(
                    child: Container(
                      width: firstGridSize,
                      height: (firstGridSize! / 9) * 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: Stack(
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                            ),
                            itemCount: 72,
                            itemBuilder: (context, index) {
                              int row = index ~/ 9;
                              int col = index % 9;

                              bool isSelected =
                                  gameProvider.selectedRow == row &&
                                      gameProvider.selectedCol == col;

                              bool isValidMove = false;
                              for (var position in gameProvider.validMoves) {
                                if (position[0] == row && position[1] == col) {
                                  isValidMove = true;
                                }
                              }

                              return DraggableBoardSquare(
                                piece: gameProvider.board[row][col],
                                index: index,
                                isSelected: isSelected,
                                isValidMove: isValidMove,
                                isReveal: gameProvider.isReveal,
                                isWhiteTurn: gameProvider.whiteTurn,
                                onTap: () => gameProvider.initializing
                                    ? gameProvider
                                        .pieceSelectedBoardInitialization(
                                            row, col)
                                    : gameProvider.pieceSelected(row, col),
                              );
                            },
                          ),

                          // ✅ Button in the center of the grid
                          if (gameProvider.initializing)
                            Center(
                                child: gameProvider.initializeArray.isEmpty
                                    ? CenterButton(
                                        title:
                                            "Player ${gameProvider.playerTurn} turn",
                                        onTap: gameProvider.newTurn)
                                    : null),
                          if (!gameProvider.initializing)
                            Center(
                              child: gameProvider.isReveal
                                  ? (gameProvider.isMoved
                                      ? CenterButton(
                                          // Show "Player 2 turn" after move
                                          title:
                                              "Player ${gameProvider.playerTurn} turn",
                                          onTap: gameProvider.newTurn,
                                        )
                                      : null)
                                  : CenterButton(
                                      // Default reveal button
                                      title: "Reveal",
                                      onTap: gameProvider.reveal,
                                    ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: firstGridSize,
                      height: (firstGridSize! / 9) * 3,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                        ),
                        itemCount: gameProvider.initializing
                            ? gameProvider.initializeArray.length
                            : gameProvider.deadPiecesArray.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              gameProvider.selectedPieceIndex == index;

                          return gameProvider.initializing
                              ? DraggableInitializationSquare(
                                  piece: gameProvider.initializeArray[index],
                                  index: index,
                                  isSelected: isSelected,
                                  onTap: () => gameProvider
                                      .pieceSelectedInitialize(index),
                                )
                              : Container(
                                  child: gameProvider.isReveal
                                      ? Image.asset(gameProvider
                                          .deadPiecesArray[index].image)
                                      : Image.asset(gameProvider
                                          .deadPiecesArray[index].hideImage!),
                                );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}
