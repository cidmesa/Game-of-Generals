import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/values/colors.dart';

// ignore: must_be_immutable
class DraggableBoardSquare extends StatefulWidget {
  GamePiece? piece;
  final int index;
  final bool isSelected;
  final bool isValidMove;
  final bool isWhiteTurn;
  final bool isReveal;
  final Function()? onTap;

  DraggableBoardSquare(
      {super.key,
      required this.piece,
      required this.index,
      required this.isSelected,
      required this.isValidMove,
      required this.isReveal,
      required this.isWhiteTurn,
      required this.onTap});

  @override
  State<DraggableBoardSquare> createState() => _DraggableBoardSquareState();
}

class _DraggableBoardSquareState extends State<DraggableBoardSquare> {
  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    Color? borderColor;

    if (widget.isSelected || widget.isValidMove) {
      squareColor = Colors.amber;
    } else if (widget.index <= 35) {
      squareColor = widget.isWhiteTurn ? tileColor1 : tileColor2;
      borderColor = widget.isWhiteTurn ? tileColor2 : tileColor1;
    } else {
      squareColor = widget.isWhiteTurn ? tileColor2 : tileColor1;
      borderColor = widget.isWhiteTurn ? tileColor1 : tileColor2;
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
                      color: borderColor ?? Colors.black,
                      width: 3.0,
                    ),
                  ),
                );
              },
              onAcceptWithDetails: (data) {
                // if no piece
                widget.onTap!();
              },
            )
          // If Has Piece
          : DragTarget<GamePiece>(
              onWillAcceptWithDetails: (data) {
                if (data.data == widget.piece) {
                  return false;
                }
                return true;
              },
              onAcceptWithDetails: (data) {
                // Eat Piece
                widget.onTap!();
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
                        color: borderColor ?? Colors.black,
                        width: 3.0,
                      ),
                    ),
                    child: Image.asset(widget.piece!.image),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                      color: squareColor,
                      border: Border.all(
                        color: borderColor ?? Colors.black,
                        width: 3.0,
                      ),
                    ),
                  ),
                  onDragStarted: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: squareColor,
                      border: Border.all(
                        color: borderColor ?? Colors.black,
                        width: 3.0,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                          widget.isWhiteTurn == widget.piece!.isWhite &&
                                  widget.isReveal
                              ? widget.piece!.image
                              : widget.piece!.hideImage!),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
