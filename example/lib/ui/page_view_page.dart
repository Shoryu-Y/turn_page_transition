import 'package:example/ui/chira_page.dart';
import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class PageViewPage extends StatelessWidget {
  const PageViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(
      10,
      (index) {
        final b = 240 ~/ 10 * index;
        final color = Color.fromARGB(255, 48, 185, b);

        return _Page(index: index, color: color);
      },
    );
    final controller = TurnPageController();
    return Scaffold(
      body: TurnPageView.builder(
        controller: controller,
        itemCount: 10,
        itemBuilder: (context, index) {
          if (index == 7) {
            final b = 240 ~/ 10 * index;
            final color = Color.fromARGB(255, 48, 185, b);

            return ChiraPage(color: color);
          }
          return pages[index];
        },
        overleafColorBuilder: (index) {
          final b = 150 ~/ 10 * index;
          return Color.fromARGB(255, 0, 100, b);
        },
        animationTransitionPoint: 0.5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateToPage(10);
        },
        child: const Text('>>'),
      ),
    );
  }
}

class _Page extends StatefulWidget {
  const _Page({
    required this.index,
    required this.color,
  });

  final int index;
  final Color color;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'page: ${widget.index + 1}',
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'count: $count',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        count++;
                      }),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
