import 'package:flutter/material.dart';
import 'package:turn_page_transition/src/const.dart';
import 'package:turn_page_transition/src/turn_direction.dart';
import 'package:turn_page_transition/src/turn_page_animation.dart';

final _defaultPageController = TurnPageController(
  initialPage: 0,
);

const _defaultThresholdValue = 0.3;

class TurnPageView extends StatefulWidget {
  TurnPageView.builder({
    Key? key,
    TurnPageController? controller,
    required this.itemCount,
    required this.itemBuilder,
    this.overleafColorBuilder,
    this.animationTransitionPoint = defaultAnimationTransitionPoint,
    this.useOnTap = true,
    this.useOnSwipe = true,
  })  : assert(itemCount > 0),
        controller = controller ?? _defaultPageController,
        super(key: key);

  final TurnPageController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Color Function(int index)? overleafColorBuilder;
  final double animationTransitionPoint;
  final bool useOnTap;
  final bool useOnSwipe;

  @override
  State<TurnPageView> createState() => _TurnPageViewState();
}

class _TurnPageViewState extends State<TurnPageView>
    with TickerProviderStateMixin {
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    widget.controller.animation = TurnAnimationController(
      vsync: this,
      initialPage: widget.controller.initialPage,
      itemCount: widget.itemCount,
      thresholdValue: widget.controller.thresholdValue,
      duration: widget.controller.duration,
    );

    pages = List.generate(
      widget.itemCount,
      (index) {
        final pageIndex = (widget.itemCount - 1) - index;
        final animation = widget.controller.animation.controllers[pageIndex];
        final page = widget.itemBuilder(context, pageIndex);

        return AnimatedBuilder(
          animation: animation,
          child: page,
          builder: (context, child) => TurnPageAnimation(
            animation: animation,
            overleafColor: widget.overleafColorBuilder?.call(pageIndex) ??
                defaultOverleafColor,
            animationTransitionPoint: widget.animationTransitionPoint,
            direction: widget.controller.direction,
            child: child ?? page,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapUp: (details) async {
          if (!widget.useOnTap) {
            return;
          }
          controller._onTapUp(
            details: details,
            constraints: constraints,
          );
        },
        onHorizontalDragUpdate: (details) {
          if (!widget.useOnSwipe) {
            return;
          }
          controller._onHorizontalDragUpdate(
            details: details,
            constraints: constraints,
          );
        },
        onHorizontalDragEnd: (_) {
          if (!widget.useOnSwipe) {
            return;
          }
          controller._onHorizontalDragEnd();
        },
        child: Stack(
          children: pages,
        ),
      ),
    );
  }
}

class TurnPageController extends ChangeNotifier {
  final int initialPage;
  final TurnDirection direction;
  final double thresholdValue;
  final Duration duration;

  TurnPageController({
    this.initialPage = 0,
    this.direction = TurnDirection.rightToLeft,
    this.thresholdValue = _defaultThresholdValue,
    this.duration = defaultTransitionDuration,
  }) : assert(0 <= thresholdValue && thresholdValue <= 1);

  late TurnAnimationController animation;

  int get currentIndex => animation.currentIndex;

  bool? isTurnForward;

  void dispose() {
    super.dispose();
    animation.dispose();
  }

  void nextPage() => animation.turnNextPage();

  void previousPage() => animation.turnPreviousPage();

  Future<void> animateToPage(int index) async {
    final diff = index - animation.currentIndex;
    for (var i = 0; i < diff.abs(); i++) {
      diff >= 0 ? animation.turnNextPage() : animation.turnPreviousPage();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void jumpToPage(int index) => animation.jump(index);

  void _onTapUp({
    required TapUpDetails details,
    required BoxConstraints constraints,
  }) {
    final isLeftSideTapped =
        details.localPosition.dx <= constraints.maxWidth / 2;

    switch (direction) {
      case TurnDirection.rightToLeft:
        isLeftSideTapped ? previousPage() : nextPage();
        break;
      case TurnDirection.leftToRight:
        isLeftSideTapped ? nextPage() : previousPage();
        break;
    }
  }

  void _onHorizontalDragUpdate({
    required DragUpdateDetails details,
    required BoxConstraints constraints,
  }) {
    final width = constraints.maxWidth;
    late final double delta;
    switch (direction) {
      case TurnDirection.rightToLeft:
        delta = -(details.primaryDelta ?? 0) / width;
        break;
      case TurnDirection.leftToRight:
        delta = (details.primaryDelta ?? 0) / width;
        break;
    }

    if (this.isTurnForward == null) {
      this.isTurnForward = delta >= 0;
    }
    final isTurnForward =
        this.isTurnForward != null ? this.isTurnForward! : delta >= 0;

    if (isTurnForward) {
      final currentPageController = animation.currentPage;
      if (currentPageController == null) {
        return;
      }
      var updated = currentPageController.value + delta;
      if (updated <= 0.0) {
        updated = 0.0;
      } else if (updated >= 1.0) {
        updated = 1.0;
      }
      animation.updateCurrentPage(updated);
      notifyListeners();
    } else {
      final previousPageController = animation.previousPage;
      if (previousPageController == null) {
        return;
      }
      var updated = previousPageController.value + delta;
      if (updated <= 0.0) {
        updated = 0.0;
      } else if (updated >= 1.0) {
        updated = 1.0;
      }
      animation.updatePreviousPage(updated);
      notifyListeners();
    }
  }

  void _onHorizontalDragEnd() {
    if (!animation.thresholdExceeded) {
      animation.reverse();
    } else {
      if (isTurnForward == true) {
        nextPage();
      }
      if (isTurnForward == false) {
        previousPage();
      }
    }
    isTurnForward = null;
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
      controller.dispose();
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

  Future<void> turnNextPage() async {
    if (isNextPageNone) {
      return;
    }
    currentPage?.animateTo(_animationMaxValue);
    currentIndex++;
  }

  Future<void> turnPreviousPage() async {
    if (isPreviousPageNone) {
      return;
    }
    previousPage?.animateTo(_animationMinValue);
    currentIndex--;
  }

  void jump(int index) {
    final diff = currentIndex - index;
    if (diff == 0) {
      return;
    }

    final isForward = diff < 0;
    for (var i = 0; i < itemCount; i++) {
      if (i == currentIndex) {
        continue;
      } else if (i < index) {
        controllers[i].value = 1.0;
      } else {
        controllers[i].value = 0.0;
      }
      controllers[index].value = isForward ? 0.0 : 1.0;
    }
    if (isForward) {
      // controllers[index].value = 0.0;
      controllers[currentIndex].animateTo(1.0);
    } else {
      controllers[index].value = 1.0;
      controllers[index].animateTo(0.0);
    }
    currentIndex = index;
  }
}
