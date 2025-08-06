import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = Routes.routes();

    return MaterialApp.router(
      title: 'TurnPageTransition Example',
      debugShowCheckedModeBanner: false,
      routerConfig: routes,
      theme: ThemeData(
        pageTransitionsTheme: const TurnPageTransitionsTheme(
          overleafColor: Colors.grey,
          overleafBorderColor: Colors.black,
          overleafBorderWidth: 2,
          animationTransitionPoint: 0.5,
        ),
        primarySwatch: Colors.blue,
      ),
      // routeInformationParser: routes.routeInformationParser,
      // routerDelegate: routes.routerDelegate,
    );
  }
}
