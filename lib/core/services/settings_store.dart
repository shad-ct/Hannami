import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/user_settings.dart';
import '../fonts.dart';

class SettingsStore {
  SettingsStore._internal();
  static final SettingsStore instance = SettingsStore._internal();

  final ValueNotifier<UserSettings> notifier = ValueNotifier<UserSettings>(
    const UserSettings(),
  );

  UserSettings get value => notifier.value;

  Future<File> _settingsFile() async {
    final appDocs = await getApplicationDocumentsDirectory();
    return File('${appDocs.path}/user_settings.json');
  }

  Future<void> load() async {
    try {
      final f = await _settingsFile();
      if (!await f.exists()) {
        return;
      }
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final themeIndex = map['themeMode'] as int? ?? ThemeMode.dark.index;
      final themeMode = ThemeMode.values.firstWhere(
        (m) => m.index == themeIndex,
        orElse: () => ThemeMode.dark,
      );
      final savedFont = map['preferredFont'] as String? ?? 'Default';
      final normalizedFont = HannamiFonts.resolve(savedFont).name;
      notifier.value = UserSettings(
        themeMode: themeMode,
        preferredFont: normalizedFont,
        accentColor: Color((map['accentColor'] as int?) ?? 0xFF70A6FF),
        backupEnabled: map['backupEnabled'] as bool? ?? false,
        dataFolderPath: map['dataFolderPath'] as String?,
      );
    } catch (_) {
      // keep defaults
    }
  }

  Future<void> update(UserSettings s) async {
    notifier.value = s;
    try {
      final f = await _settingsFile();
      final map = {
        'themeMode': s.themeMode.index,
        'preferredFont': s.preferredFont,
        'accentColor': s.accentColor.value,
        'backupEnabled': s.backupEnabled,
        'dataFolderPath': s.dataFolderPath,
      };
      await f.writeAsString(jsonEncode(map));
    } catch (_) {
      // ignore persistence errors
    }
  }
}
