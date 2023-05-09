# turn_page_transition
turn_page_transition provide simple **Page-Turning Transition** to your app.

## Demo
### Transition
<img src="https://user-images.githubusercontent.com/44453803/174470088-18e616cc-26ef-4e7d-aaf6-d1967f974722.gif" height="600px">

### PageView
<img src="https://user-images.githubusercontent.com/44453803/236710810-f13b9563-517c-4287-99c6-465cd231c1b7.gif" height="600px">

## Usage
### Case 1: Use as PageRoute in Navigator
```dart
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
                  overleafColor: Colors.grey,
                  animationTransitionPoint: animationTransitionPoint,
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
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
```dart
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
        pageTransitionsTheme: const TurnPageTransitionsTheme(
          overleafColor: Colors.grey,
          animationTransitionPoint: 0.5,
        ),
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: routes.routeInformationParser,
      routerDelegate: routes.routerDelegate,
    );
  }
}
```

### Case 3: Use Page-Turning Transition with GoRoute
```dart
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
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) => TurnPageTransition(
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
```

### Case 4: Use Page-Turning View
```dart
class PageViewPage extends StatelessWidget {
  const PageViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TurnPageController();
    return Scaffold(
      body: TurnPageView.builder(
        controller: controller,
        itemCount: 10,
        itemBuilder: (context, index) => _Page(index),
        overleafColorBuilder: (index) => colors[index],
        animationTransitionPoint: 0.5,
      ),
    );
  }
}
```