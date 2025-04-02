import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:game_of_generals/provider/ai_game_provider.dart'; // Import your GameProvider

// ignore: must_be_immutable
class AICenterButton extends StatelessWidget {
  Function onTap;
  final String title;
  AICenterButton({super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<AIGameprovider>(context);
    return Container(
      height: 60, // Reduce height to make the space around the button smaller
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: gameProvider.initializeArray.isNotEmpty
            ? null
            : () {
                onTap();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00267e),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8), // Smaller padding
          minimumSize: const Size(80, 40), // Set minimum width and height
        ),
        child: Text(title,
            style: TextStyle(
                fontFamily: 'Eurostile Bold', fontSize: 18)), // Smaller text
      ),
    );
  }
}
