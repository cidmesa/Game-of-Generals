import 'package:flutter/material.dart';
import 'package:game_of_generals/components/ai_center_button.dart';
import 'package:game_of_generals/components/draggable_initialization_square.dart';
import 'package:game_of_generals/provider/ai_game_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:game_of_generals/components/draggable_board_square.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/components/help.dart'; // Import Help

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AIGameprovider(),
        )
      ],
      child: const MaterialApp(
        home: AIGameBoard(),
      ),
    ),
  );
}

class AIGameBoard extends StatefulWidget {
  const AIGameBoard({super.key});

  @override
  State<AIGameBoard> createState() => _AIGameBoardState();
}

class _AIGameBoardState extends State<AIGameBoard> {
  late GamePiece whiteGeneral5;
  late GamePiece whiteGeneral4;

  bool isGeneral5Used = false;
  bool isGeneral4Used = false;

  // 👇 Variable to store the grid size
  double? firstGridSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<AIGameprovider>(builder: (context, gameProvider, child) {
      if (gameProvider.gameWin) {
        Future.microtask(() => showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              builder: (
                context,
              ) =>
                  AlertDialog(
                title: gameProvider.whiteTurn
                    ? Text("White win!",
                        style: TextStyle(
                            fontFamily: 'Eurostile Bold', fontSize: 18))
                    : Text("AI wins!",  // Changed from "Black win!" to "AI wins!"
                        style: TextStyle(
                            fontFamily: 'Eurostile Bold', fontSize: 18)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      gameProvider.resetGame(); // Reset game
                    },
                    child: const Text("Reset Game",
                        style: TextStyle(
                            fontFamily: 'Eurostile Bold', fontSize: 18)),
                  )
                ],
              ),
            ));
      }
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "lib/assets/Title.png",
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          backgroundColor: Color(0xFF00267e),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
              ), // Help Icon
              onPressed: () => Help.show(context), // Show Help Overlay
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ), // Help Icon
              onPressed: () {
                gameProvider.resetGame(); // Reset the game state
                context.pop();
              }, // Show Help Overlay
            )
          ],
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("lib/assets/Game_BG.png"),
                  fit: BoxFit.cover)),
          child: Column(
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
                          border:
                              Border.all(color: Color(0xFF00267e), width: 5),
                        ),
                        child: Stack(
                          children: [
                            ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: GridView.builder(
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
                                  for (var position
                                      in gameProvider.validMoves) {
                                    if (position[0] == row &&
                                        position[1] == col) {
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
                            ),

                            // ✅ Button in the center of the grid
                            if (gameProvider.initializing)
                              Center(
                                  child: gameProvider.initializeArray.isEmpty
                                      ? AICenterButton(
                                          title: "Continue", // Changed button text
                                          onTap: gameProvider.newTurn)
                                      : null),
                            if (!gameProvider.initializing)
                              Center(
                                child: 
                                    (gameProvider.isMoved
                                        ? AICenterButton(
                                            // Show "AI's turn" after move
                                            title: gameProvider.whiteTurn
                                                ? "Continue" // Changed from "White's turn"
                                                : "AI's Turn", // Changed from "Black's Turn"
                                            onTap: gameProvider.whiteTurn ? gameProvider.newTurn : (){},
                                          )
                                        : null),
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
        ),
      );
    });
  }
}