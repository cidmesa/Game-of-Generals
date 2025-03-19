import 'package:flutter/material.dart';
import 'package:game_of_generals/provider/GameProvider.dart';
import 'package:provider/provider.dart';
import 'package:game_of_generals/components/draggable_board_square.dart';
import 'package:game_of_generals/components/game_piece.dart';

void main() {
  runApp(GameBoard());
}

class GameBoard extends StatelessWidget {
  GameBoard({super.key});

  GamePiece whiteGeneral5 = GamePiece(
      type: GamePieceType.star5,
      isWhite: true,
      image: 'assets/White_5Star.png');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Gameprovider(),
        )
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title:
                Text("Game of Generals", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Get screen dimensions
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              // Calculate the size of the grid to fit on the screen
              double gridSize = screenWidth < screenHeight
                  ? screenWidth * 0.95 // Fit horizontally
                  : screenHeight * 0.95; // Fit vertically

              return Center(
                child: Container(
                  width: gridSize,
                  height: (gridSize / 9) * 8, // Maintain 9x8 aspect ratio
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 72,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;

                      bool target = row == 7 && col == 0;

                      return DraggableBoardSquare(
                        piece: target ? whiteGeneral5 : null,
                        index: index,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
