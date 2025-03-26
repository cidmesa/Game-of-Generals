import 'package:flutter/material.dart';
import 'package:game_of_generals/components/action_button.dart';
import 'package:game_of_generals/provider/game_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:game_of_generals/components/help.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonHeight = MediaQuery.of(context).size.width / 22;
    double titlePadding = MediaQuery.of(context).size.width / 12;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/assets/Home_BG.png"),
                fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: titlePadding,
                  right: titlePadding,
                  bottom: titlePadding),
              child: Image.asset("lib/assets/Title.png"),
            ),
            Container(
              color: Color(0xFF00267e).withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                        onTap: () {
                          context.pushNamed("/GameBoard");
                          Provider.of<Gameprovider>(context, listen: false).initializeBoard();
                        },
                        child: Image.asset(
                          "lib/assets/Play_Button.png",
                          height: buttonHeight,
                        )),
                    ActionButton(
                        onTap: () => Help.show(context),
                        child: Image.asset(
                          "lib/assets/Tutorial_Button.png",
                          height: buttonHeight,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
