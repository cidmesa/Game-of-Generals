import 'package:flutter/material.dart';
import 'package:game_of_generals/helper/routing.dart';
import 'package:game_of_generals/provider/ai_game_provider.dart';
import 'package:game_of_generals/provider/pvp_game_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AIGameprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PvpGameprovider(),
        )
      ],
      
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
