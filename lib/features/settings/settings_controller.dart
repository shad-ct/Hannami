import '../../models/user_settings.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/settings_store.dart';
import 'dart:io';

class SettingsController {
  final StorageService _storage = const StorageService();
  UserSettings _settings = const UserSettings();

  UserSettings get settings => _settings;

  Future<UserSettings> load() async {
    await SettingsStore.instance.load();
    _settings = SettingsStore.instance.value;
    return _settings;
  }

  Future<void> update(UserSettings s) async {
    _settings = s;
    await SettingsStore.instance.update(s);
  }

  Future<File?> exportCsv() => _storage.exportEntriesCsv();
}
