import 'package:example/ui/first_page.dart';
import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

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
                TurnPageRoute(
                  overleafColor: Colors.black12,
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
