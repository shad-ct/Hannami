import 'package:flutter/material.dart';
import '../../app/app_navigation.dart';

class SwipeNav extends StatefulWidget {
  final String? currentRoute;
  final Widget child;
  const SwipeNav({super.key, required this.currentRoute, required this.child});

  @override
  State<SwipeNav> createState() => _SwipeNavState();
}

class _SwipeNavState extends State<SwipeNav> {
  double _accumulatedDx = 0.0;

  void _handleEnd(DragEndDetails details) {
    const threshold = 90.0; // pixels
    final idx = AppNavigation.indexFromRoute(widget.currentRoute);
    if (_accumulatedDx <= -threshold) {
      final next = (idx + 1).clamp(0, 3);
      if (next != idx) AppNavigation.navigateIndex(context, next);
    } else if (_accumulatedDx >= threshold) {
      final prev = (idx - 1).clamp(0, 3);
      if (prev != idx) AppNavigation.navigateIndex(context, prev);
    }
    _accumulatedDx = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) => _accumulatedDx += d.delta.dx,
      onHorizontalDragEnd: _handleEnd,
      child: widget.child,
    );
  }
}
