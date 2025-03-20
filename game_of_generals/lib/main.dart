import 'package:flutter/material.dart';
import 'package:game_of_generals/screens/game_board.dart';
import 'package:game_of_generals/provider/GameProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Gameprovider(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GameBoard(),
      ),
    ),
  );
}
