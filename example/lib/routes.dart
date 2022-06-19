import 'package:example/ui/first_page.dart';
import 'package:example/ui/home_page.dart';
import 'package:example/ui/second_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  const Routes();

  static const first = '/first';
  static const second = '/second';
  static const home = '/';

  static GoRouter routes({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation ?? home,
      redirect: (state) => null,
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
          builder: (context, state) => const SecondPage(),
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(),
    );
  }
}
