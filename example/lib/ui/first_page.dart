import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('First Page'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('back to home page'),
            ),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).push(Routes.second),
              child: const Text('go to second page'),
            ),
          ],
        ),
      ),
    );
  }
}
