import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/media/media_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/diary/diary_detail_screen.dart';
import '../models/diary_entry.dart';
import 'main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String media = '/media';
  static const String settings = '/settings';
  static const String diaryDetail = '/diary-detail';
  static const String root = '/';

  static final Map<String, WidgetBuilder> routes = {
    root: (_) => const MainShell(),
    home: (_) => const HomeScreen(),
    calendar: (_) => const CalendarScreen(),
    media: (_) => const MediaScreen(),
    settings: (_) => const SettingsScreen(),
    diaryDetail: (context) {
      final entry = ModalRoute.of(context)?.settings.arguments as DiaryEntry?;
      return DiaryDetailScreen(entry: entry);
    },
  };
}
