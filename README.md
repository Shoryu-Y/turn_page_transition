# turn_page_transition
turn_page_transition provide simple **Page-Turning Transition** to your app.

## Demo
<img src="https://user-images.githubusercontent.com/44453803/174470088-18e616cc-26ef-4e7d-aaf6-d1967f974722.gif" height = 600px>

## Usage
### Case 1: Use as PageRoute in Navigator
```
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                // Use TurnPageRoute instead of MaterialPageRoute.
                TurnPageRoute(
                  builder: (context) => const FirstPage(),
                ),
              ),
              child: const Text('go to next page'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Case 2: Unify transition animations by ThemeData
```
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final routes = Routes.routes();

    return MaterialApp.router(
      title: 'TurnPageTransition Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set TurnPageTransitionsTheme() at pageTransitionsTheme argument.
        pageTransitionsTheme: const TurnPageTransitionsTheme(),
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: routes.routeInformationParser,
      routerDelegate: routes.routerDelegate,
    );
  }
}
```

### Case 3: Use Page-Turning Transition with GoRoute
```
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
          // Use TurnPageTransition in CustomTransitionPage.
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const SecondPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    TurnPageTransition(
              animation: animation,
              color: Colors.greenAccent,
              child: child,
            ),
          ),
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(),
    );
  }
}
```
