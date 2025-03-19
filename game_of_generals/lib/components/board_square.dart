import "package:flutter/material.dart";

class BoardSquare extends StatelessWidget {
  final int index;
  const BoardSquare({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: index <= 35 ? Colors.black : Colors.white,
        border: Border.all(
          color:
              index <= 35 ? Colors.white : Colors.black, // White border color
          width: 3.0, // Border thickness
        ),
      ),
      child: Text(index.toString()),
    );
  }
}
