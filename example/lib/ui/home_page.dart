import 'package:example/ui/first_page.dart';
import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final ratio = deviceSize.width / deviceSize.height;
    print('ratio: $ratio, judge: ${ratio < 9 / 16}');
    final turningPoint = ratio < 9 / 16 ? 0.5 : 0.1;

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
                  overleafColor: Colors.grey,
                  turningPoint: turningPoint,
                  transitionDuration: const Duration(seconds: 1),
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
