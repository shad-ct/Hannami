import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/diary_entry.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/image_service.dart';

class DiaryController {
  final StorageService _storageService = const StorageService();
  final ImageService _imageService = ImageService();

  DiaryController();

  Future<List<File>> pickImagesAndStoreTemp() async {
    final List<XFile> picked = await _imageService.pickImages();
    final dir = await _storageService.diaryDirectory();
    final stored = <File>[];
    for (final x in picked) {
      stored.add(await _imageService.copyToDirectory(x, dir));
    }
    return stored;
  }

  Future<DiaryEntry> createAndPersist({
    required String title,
    required String content,
    String mood = 'neutral',
    List<File> imageFiles = const [],
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = DiaryEntry(
      id: id,
      title: title,
      content: content,
      dateTime: DateTime.now(),
      mood: mood,
      imagePaths: imageFiles.map((f) => f.path).toList(),
      latitude: null,
      longitude: null,
      weatherSummary: null,
      placeName: null,
    );
    await _storageService.saveEntry(entry);
    return entry;
  }

  Future<DiaryEntry> updateAndPersist(
    DiaryEntry existing, {
    String? title,
    String? content,
    String? mood,
    List<String>? imagePaths, // full replacement when provided
  }) async {
    final updated = existing.copyWith(
      title: title?.trim().isEmpty == true ? existing.title : title ?? existing.title,
      content: content?.trim() ?? existing.content,
      mood: mood ?? existing.mood,
      imagePaths: imagePaths ?? existing.imagePaths,
      // location & weather removed
      latitude: null,
      longitude: null,
      weatherSummary: null,
      placeName: null,
    );
    await _storageService.saveEntry(updated);
    return updated;
  }

  Future<void> deleteEntry(String id) async {
    await _storageService.deleteEntry(id);
  }
}
