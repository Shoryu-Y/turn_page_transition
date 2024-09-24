import 'package:example/ui/first_page.dart';
import 'package:example/ui/home_page.dart';
import 'package:example/ui/second_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class Routes {
  const Routes();

  static const home = '/';
  static const first = '/first';
  static const second = '/second';

  static GoRouter routes({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation ?? home,
      // redirect: (context, state) => null,
      routes: [
        GoRoute(
          path: home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: first,
          builder: (context, state) => const FirstPage(),
        ),
        GoRoute(
          path: second,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const SecondPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) =>
                TurnPageTransition(
              animation: animation,
              overleafColor: Colors.blueAccent,
              animationTransitionPoint: 0.5,
              direction: TurnDirection.rightToLeft,
              child: child,
            ),
          ),
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(),
    );
  }
}
