import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/diary_entry.dart';
import '../../models/user_settings.dart';
import 'package:flutter/material.dart';
import 'settings_store.dart';

class StorageService {
  const StorageService();

  Future<Directory> _baseDataDirectory() async {
    final settings = SettingsStore.instance.value;
    if (settings.dataFolderPath != null && settings.dataFolderPath!.isNotEmpty) {
      final dir = Directory(settings.dataFolderPath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final appDocs = await getApplicationDocumentsDirectory();
    final fallback = Directory('${appDocs.path}/hannami_data');
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback;
  }

  Future<Directory> diaryDirectory() async {
    final base = await _baseDataDirectory();
    final diaryDir = Directory('${base.path}/diary_entries');
    if (!await diaryDir.exists()) {
      await diaryDir.create(recursive: true);
    }
    return diaryDir;
  }

  Future<File> _entryFile(String id) async {
    final d = await diaryDirectory();
    return File('${d.path}/$id.json');
  }

  Future<void> saveEntry(DiaryEntry entry) async {
    final file = await _entryFile(entry.id);
    final jsonStr = jsonEncode(entry.toJson());
    await file.writeAsString(jsonStr);
  }

  Future<List<DiaryEntry>> loadEntries() async {
    final d = await diaryDirectory();
    final files = d.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
    final entries = <DiaryEntry>[];
    for (final f in files) {
      try {
        final content = await f.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        entries.add(DiaryEntry.fromJson(map));
      } catch (_) {}
    }
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return entries;
  }

  Future<void> deleteEntry(String id) async {
    final file = await _entryFile(id);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  Future<File?> exportEntriesCsv() async {
    final d = await diaryDirectory();
    final entries = await loadEntries();
    if (entries.isEmpty) return null;
    final csvFile = File('${d.path}/diary_export.csv');
    final sink = csvFile.openWrite();
    sink.writeln('id,title,content,dateTime,mood,images,tags,latitude,longitude,weather');
    for (final e in entries) {
      final esc = (String v) => '"${v.replaceAll('"', '""')}"';
      sink.writeln([
        esc(e.id),
        esc(e.title),
        esc(e.content),
        e.dateTime.toIso8601String(),
        esc(e.mood),
        esc(e.imagePaths.join('|')),
        esc(e.tags.join('|')),
        e.latitude?.toString() ?? '',
        e.longitude?.toString() ?? '',
        esc(e.weatherSummary ?? ''),
      ].join(','));
    }
    await sink.close();
    return csvFile;
  }

  Future<File> _settingsFile() async {
    final appDocs = await getApplicationDocumentsDirectory();
    return File('${appDocs.path}/user_settings.json');
  }

  Future<UserSettings> loadUserSettings() async {
    final f = await _settingsFile();
    if (!await f.exists()) return const UserSettings();
    try {
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final themeIndex = map['themeMode'] as int? ?? ThemeMode.dark.index;
      final themeMode = ThemeMode.values.firstWhere(
        (m) => m.index == themeIndex,
        orElse: () => ThemeMode.dark,
      );
      return UserSettings(
        themeMode: themeMode,
        preferredFont: map['preferredFont'] as String? ?? 'Default',
        accentColor: Color((map['accentColor'] as int?) ?? 0xFF70A6FF),
        backupEnabled: map['backupEnabled'] as bool? ?? false,
        dataFolderPath: map['dataFolderPath'] as String?,
      );
    } catch (_) {
      return const UserSettings();
    }
  }

  Future<void> saveUserSettings(UserSettings s) async {
    final f = await _settingsFile();
    final map = {
      'themeMode': s.themeMode.index,
      'preferredFont': s.preferredFont,
      'accentColor': s.accentColor.value,
      'backupEnabled': s.backupEnabled,
      'dataFolderPath': s.dataFolderPath,
    };
    await f.writeAsString(jsonEncode(map));
  }

  Future<File?> exportImage(File imageFile) async {
    if (!await imageFile.exists()) return null;
    final base = await _baseDataDirectory();
    final exportDir = Directory('${base.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final baseName = imageFile.uri.pathSegments.isNotEmpty ? imageFile.uri.pathSegments.last : 'image.jpg';
    final newName = '${DateTime.now().millisecondsSinceEpoch}_$baseName';
    final newFile = File('${exportDir.path}/$newName');
    return imageFile.copy(newFile.path);
  }
}
