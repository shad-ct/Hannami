import 'package:flutter/material.dart';
import '../core/widgets/bottom_nav.dart';
import '../features/home/home_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/media/media_screen.dart';
import '../features/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          HomeScreen(showBottomNav: false, enableSwipeNav: false),
          CalendarScreen(showBottomNav: false, enableSwipeNav: false),
          MediaScreen(showBottomNav: false, enableSwipeNav: false),
          SettingsScreen(showBottomNav: false, enableSwipeNav: false),
        ],
      ),
      bottomNavigationBar: HannamiBottomNav(
        selectedIndex: _index,
        onIndexChange: (i) {
          setState(() => _index = i);
          _controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}
