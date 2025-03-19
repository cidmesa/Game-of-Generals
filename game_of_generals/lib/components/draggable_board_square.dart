import 'package:flutter/material.dart';
import 'package:game_of_generals/components/game_piece.dart';
import 'package:game_of_generals/values/colors.dart';

// ignore: must_be_immutable
class DraggableBoardSquare extends StatefulWidget {
  GamePiece? piece;
  final int index;

  DraggableBoardSquare({super.key, required this.piece, required this.index});

  @override
  State<DraggableBoardSquare> createState() => _DraggableBoardSquareState();
}

class _DraggableBoardSquareState extends State<DraggableBoardSquare> {
  @override
  Widget build(BuildContext context) {
    return widget.piece == null
        ? DragTarget<GamePiece>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: widget.index <= 35 ? tileColor1 : tileColor2,
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
                // TODO: State if has piece inside square
                widget.piece = data.data;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<GamePiece>(
                delay: Duration(milliseconds: 300),
                data: widget.piece,
                onDragCompleted: () => setState(() {
                  widget.piece = null;
                }),
                feedback: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.index <= 35 ? tileColor1 : tileColor2,
                    border: Border.all(
                      color: widget.index <= 35 ? tileColor2 : tileColor1,
                      width: 3.0,
                    ),
                  ),
                  child: Image.asset(widget.piece!.image),
                ),
                childWhenDragging: Container(
                  decoration: BoxDecoration(
                    color: widget.index <= 35 ? tileColor1 : tileColor2,
                    border: Border.all(
                      color: widget.index <= 35 ? tileColor2 : tileColor1,
                      width: 3.0,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.index <= 35 ? tileColor1 : tileColor2,
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
          );
  }
}
