import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart' as Const;
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_animation.dart';

class TurnPageView extends StatefulWidget {
  const TurnPageView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.overleafColorBuilder,
    this.direction = TurnDirection.rightToLeft,
    this.initialPage = 0,
    this.thresholdValue = Const.defaultThresholdValue,
    this.duration = Const.defaultTransitionDuration,
    this.useOnTap = true,
    this.useOnSwipe = true,
  })  : assert(itemCount > 0),
        assert(0 <= initialPage && initialPage < itemCount),
        assert(0 <= thresholdValue && thresholdValue <= 1),
        super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Color Function(int index)? overleafColorBuilder;
  final TurnDirection direction;
  final int initialPage;
  final double thresholdValue;
  final Duration duration;
  final bool useOnTap;
  final bool useOnSwipe;

  @override
  State<TurnPageView> createState() => _TurnPageViewState();
}

class _TurnPageViewState extends State<TurnPageView>
    with TickerProviderStateMixin {
  late final TurnAnimationController controller;
  late final List<Widget> pages;
  bool? isTurnForward;

  @override
  void initState() {
    super.initState();
    controller = TurnAnimationController(
      vsync: this,
      initialPage: widget.initialPage,
      itemCount: widget.itemCount,
      thresholdValue: widget.thresholdValue,
      duration: widget.duration,
    );

    pages = List.generate(
      widget.itemCount,
      (index) {
        final pageIndex = (widget.itemCount - 1) - index;
        final controller = this.controller.controllers[pageIndex];
        final page = widget.itemBuilder(context, pageIndex);

        return AnimatedBuilder(
          animation: controller,
          child: page,
          builder: (context, child) => TurnPageAnimation(
            animation: controller,
            overleafColor: widget.overleafColorBuilder?.call(pageIndex) ??
                Const.defaultOverleafColor,
            child: child ?? page,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) => GestureDetector(
        onTapUp: (detail) async {
          if (!widget.useOnTap) {
            return;
          }

          final isLeftSideTapped =
              detail.localPosition.dx <= constraint.maxWidth / 2;
          switch (widget.direction) {
            case TurnDirection.rightToLeft:
              isLeftSideTapped
                  ? await controller.turnBackward()
                  : await controller.turnForward();
              break;
            case TurnDirection.leftToRight:
              isLeftSideTapped
                  ? await controller.turnForward()
                  : await controller.turnBackward();
              break;
          }
        },
        onHorizontalDragUpdate: (detail) {
          if (!widget.useOnSwipe) {
            return;
          }

          final width = constraint.maxWidth;
          late final double delta;
          switch (widget.direction) {
            case TurnDirection.rightToLeft:
              delta = -(detail.primaryDelta ?? 0) / width;
              break;
            case TurnDirection.leftToRight:
              delta = detail.primaryDelta ?? 0 / width;
              break;
          }

          if (this.isTurnForward == null) {
            this.isTurnForward = delta >= 0;
          }
          final isTurnForward =
              this.isTurnForward != null ? this.isTurnForward! : delta >= 0;

          if (isTurnForward) {
            final currentPageController = controller.currentPage;
            if (currentPageController == null) {
              return;
            }
            var updated = currentPageController.value + delta;
            if (updated <= 0.0) {
              updated = 0.0;
            } else if (updated >= 1.0) {
              updated = 1.0;
            }
            setState(() {
              controller.updateCurrentPage(updated);
            });
          } else {
            final previousPageController = controller.previousPage;
            if (previousPageController == null) {
              return;
            }
            var updated = previousPageController.value + delta;
            if (updated <= 0.0) {
              updated = 0.0;
            } else if (updated >= 1.0) {
              updated = 1.0;
            }
            setState(() {
              controller.updatePreviousPage(updated);
            });
          }
        },
        onHorizontalDragEnd: (detail) {
          if (!controller.thresholdExceeded) {
            controller.reverse();
          } else {
            if (isTurnForward == true) {
              controller.turnForward();
            }
            if (isTurnForward == false) {
              controller.turnBackward();
            }
          }
          isTurnForward = null;
        },
        child: Stack(
          children: pages,
        ),
      ),
    );
  }
}

class TurnAnimationController {
  static const _animationMinValue = 0.0;
  static const _animationMaxValue = 1.0;

  final int initialPage;
  final int itemCount;
  final double thresholdValue;
  final Duration duration;
  final List<AnimationController> controllers;

  int currentIndex;

  TurnAnimationController({
    required TickerProvider vsync,
    required this.initialPage,
    required this.itemCount,
    required this.thresholdValue,
    required this.duration,
  })  : currentIndex = initialPage,
        controllers = List.generate(
          itemCount,
          (index) => AnimationController(
            vsync: vsync,
            duration: duration,
            value:
                index < initialPage ? _animationMaxValue : _animationMinValue,
          ),
        );

  AnimationController? get previousPage =>
      currentIndex > 0 ? controllers[currentIndex - 1] : null;

  AnimationController? get currentPage =>
      currentIndex < itemCount - 1 ? controllers[currentIndex] : null;

  bool get thresholdExceeded {
    final currentPage = this.currentPage;
    final previousPage = this.previousPage;
    return currentPage != null && currentPage.value >= thresholdValue ||
        previousPage != null && previousPage.value < (1 - thresholdValue);
  }

  bool get isNextPageNone => currentIndex + 1 >= itemCount;

  bool get isPreviousPageNone => currentIndex - 1 < 0;

  void dispose() {
    for (final controller in controllers) {
      controller.dispose;
    }
  }

  Future<void> reverse() async {
    if (previousPage?.value != _animationMaxValue) {
      await previousPage?.animateTo(_animationMaxValue);
    }
    if (currentPage?.value != _animationMinValue) {
      await currentPage?.animateTo(_animationMinValue);
    }
  }

  void updateCurrentPage(double value) {
    if (isNextPageNone) {
      return;
    }
    currentPage?.value = value;
  }

  void updatePreviousPage(double value) {
    if (isPreviousPageNone) {
      return;
    }
    previousPage?.value = value;
  }

  Future<void> turnForward() async {
    if (isNextPageNone) {
      return;
    }
    await currentPage?.animateTo(_animationMaxValue);
    currentIndex++;
  }

  Future<void> turnBackward() async {
    if (isPreviousPageNone) {
      return;
    }
    await previousPage?.animateTo(_animationMinValue);
    currentIndex--;
  }
}
