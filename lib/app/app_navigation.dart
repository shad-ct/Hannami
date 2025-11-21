import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppNavigation {
  const AppNavigation._();

  static void navigateIndex(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.calendar,
      2 => AppRoutes.media,
      3 => AppRoutes.settings,
      _ => AppRoutes.home,
    };
    final currentName = ModalRoute.of(context)?.settings.name;
    if (currentName == route) return;

    final currentIndex = indexFromRoute(currentName);
    final forward = index > currentIndex;

    final builder = AppRoutes.routes[route];
    if (builder == null) {
      Navigator.pushReplacementNamed(context, route);
      return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => builder(context),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (_, animation, secondary, child) {
          final begin = Offset(forward ? 1 : -1, 0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  static int indexFromRoute(String? name) {
    return switch (name) {
      AppRoutes.home => 0,
      AppRoutes.calendar => 1,
      AppRoutes.media => 2,
      AppRoutes.settings => 3,
      _ => 0,
    };
  }
}
