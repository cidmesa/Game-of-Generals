import 'package:flutter/material.dart';
import 'package:game_of_generals/provider/game_provider.dart';
import 'package:game_of_generals/screens/home.dart';
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
        home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: AspectRatio(aspectRatio: 16 / 9, child: Home()),
            )),
      ),
    ),
  );
}
