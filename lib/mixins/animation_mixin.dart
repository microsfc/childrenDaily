import 'package:flutter/material.dart';

mixin AnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  void initializeAnimations({
    Duration duration = const Duration(milliseconds: 1200),
    Curve curve = Curves.easeInOut,
    Curve slideCurve = Curves.easeOutCubic,
    Offset slideBegin = const Offset(0, 0.3),
    Offset slideEnd = Offset.zero,
  }) {
    animationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: curve,
    ));

    slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: slideCurve,
    ));

    animationController.forward();
  }

  void disposeAnimations() {
    animationController.dispose();
  }

  Widget buildAnimatedWidget(Widget child) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
