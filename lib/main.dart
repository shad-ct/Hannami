import 'package:flutter/material.dart';
import 'app/app_theme.dart';
import 'app/app_routes.dart';
import 'core/services/settings_store.dart';
import 'models/user_settings.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const HannamiApp());

class HannamiApp extends StatefulWidget {
  const HannamiApp({super.key});

  @override
  State<HannamiApp> createState() => _HannamiAppState();
}

class _HannamiAppState extends State<HannamiApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await SettingsStore.instance.load();
    final s = SettingsStore.instance.value;
    if (s.dataFolderPath == null || s.dataFolderPath!.isEmpty) {
      await _requestStorageIfNeeded();
      final path = await getDirectoryPath(confirmButtonText: 'Use This Folder');
      if (path != null && path.isNotEmpty) {
        await SettingsStore.instance.update(s.copyWith(dataFolderPath: path));
      }
    }
    if (mounted) setState(() => _initialized = true);
  }

  Future<void> _requestStorageIfNeeded() async {
    if (Platform.isAndroid) {
      // Request broad storage permissions on Android when available
      final statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.photos,
      ].request();
      // We won't block on denial here; SAF may still work.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Initializing…'),
              ],
            ),
          ),
        ),
      );
    }
    return ValueListenableBuilder<UserSettings>(
      valueListenable: SettingsStore.instance.notifier,
      builder: (_, s, __) {
        final light = AppTheme.themed(accent: s.accentColor, brightness: Brightness.light);
        final dark = AppTheme.themed(accent: s.accentColor, brightness: Brightness.dark);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hannami',
          theme: light,
          darkTheme: dark,
          themeMode: s.themeMode,
          initialRoute: AppRoutes.root,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
