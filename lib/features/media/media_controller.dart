import '../../core/services/storage_service.dart';
import '../../models/diary_entry.dart';
import 'dart:io';

class MediaController {
  final StorageService _storage = const StorageService();
  MediaController();

  Future<List<File>> loadImages() async {
    final entries = await _storage.loadEntries();
    final paths = <String>{ for (final e in entries) ...e.imagePaths };
    return paths.map((p) => File(p)).where((f) => f.existsSync()).toList();
  }

  Future<DiaryEntry?> entryForImage(String path) async {
    final entries = await _storage.loadEntries();
    for (final e in entries) {
      if (e.imagePaths.contains(path)) return e;
    }
    return null;
  }

  Future<File?> exportImage(File file) async => _storage.exportImage(file);
}
