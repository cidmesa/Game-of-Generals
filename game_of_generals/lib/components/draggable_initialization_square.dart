import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/values/colors.dart';

// ignore: must_be_immutable
class DraggableInitializationSquare extends StatefulWidget {
  GamePiece? piece;
  final int index;
  final bool isSelected;
  final Function()? onTap;

  DraggableInitializationSquare(
      {super.key,
      required this.piece,
      required this.index,
      required this.isSelected,
      required this.onTap});

  @override
  State<DraggableInitializationSquare> createState() =>
      _DraggableInitializationSquare();
}

class _DraggableInitializationSquare
    extends State<DraggableInitializationSquare> {
  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (widget.isSelected) {
      squareColor = Colors.amber;
    } else if (widget.index <= 35) {
      squareColor = tileColor1;
    } else {
      squareColor = tileColor2;
    }
    return GestureDetector(
      onTap: () {
        widget.onTap!();
      },
      child: widget.piece == null
          ? DragTarget<GamePiece>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: squareColor,
                    border: Border.all(
                      color: widget.index <= 35 ? tileColor2 : tileColor1,
                      width: 3.0,
                    ),
                  ),
                );
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  widget.piece = data.data;
                });
              },
            )
          : DragTarget<GamePiece>(
              onWillAcceptWithDetails: (data) {
                if (data.data == widget.piece) {
                  return false;
                }
                return true;
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  widget.piece = data.data;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return LongPressDraggable<GamePiece>(
                  delay: Duration(milliseconds: 300),
                  data: widget.piece,
                  onDragCompleted: () => setState(() {}),
                  feedback: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: squareColor,
                      border: Border.all(
                        color: widget.index <= 35 ? tileColor2 : tileColor1,
                        width: 3.0,
                      ),
                    ),
                    child: Image.asset(widget.piece!.image),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                      color: squareColor,
                      border: Border.all(
                        color: widget.index <= 35 ? tileColor2 : tileColor1,
                        width: 3.0,
                      ),
                    ),
                  ),
                  onDragStarted: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: squareColor,
                      border: Border.all(
                        color: widget.index <= 35 ? tileColor2 : tileColor1,
                        width: 3.0,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(widget.piece!.image),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
