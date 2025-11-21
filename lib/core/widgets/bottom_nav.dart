import 'package:flutter/material.dart';
import '../../app/app_navigation.dart';

class HannamiBottomNav extends StatelessWidget {
  final String? currentRoute;
  final int? selectedIndex;
  final ValueChanged<int>? onIndexChange;
  const HannamiBottomNav({super.key, this.currentRoute, this.selectedIndex, this.onIndexChange});

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex ?? AppNavigation.indexFromRoute(currentRoute);
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: index,
      onDestinationSelected: (i) => onIndexChange != null ? onIndexChange!(i) : AppNavigation.navigateIndex(context, i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.image),
          label: 'Media',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
