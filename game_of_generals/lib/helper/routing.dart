import 'package:flutter/material.dart';
import 'package:game_of_generals/screens/game_board.dart';
import 'package:game_of_generals/screens/home.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: "/Home",
  routes: [
    GoRoute(
        name: "/Home",
        path: "/Home",
        builder: (context, state) {
          return Home();
        }),
    GoRoute(
      name: "/GameBoard",
      path: "/GameBoard",
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameBoard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.fastOutSlowIn;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
