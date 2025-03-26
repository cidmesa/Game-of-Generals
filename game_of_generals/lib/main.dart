import 'package:flutter/material.dart';
import 'package:game_of_generals/helper/routing.dart';
import 'package:game_of_generals/provider/game_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Gameprovider(),
        )
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
