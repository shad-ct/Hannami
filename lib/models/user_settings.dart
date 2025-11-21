import 'package:flutter/material.dart';

class UserSettings {
  final ThemeMode themeMode;
  final String preferredFont;
  final Color accentColor;
  final bool backupEnabled;
  final String? dataFolderPath;

  const UserSettings({
    this.themeMode = ThemeMode.dark,
    this.preferredFont = 'Default',
    this.accentColor = const Color(0xFF70A6FF),
    this.backupEnabled = false,
    this.dataFolderPath,
  });

  UserSettings copyWith({
    ThemeMode? themeMode,
    String? preferredFont,
    Color? accentColor,
    bool? backupEnabled,
    String? dataFolderPath,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      preferredFont: preferredFont ?? this.preferredFont,
      accentColor: accentColor ?? this.accentColor,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      dataFolderPath: dataFolderPath ?? this.dataFolderPath,
    );
  }
}
