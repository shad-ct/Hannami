import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/diary_entry.dart';
import '../../core/services/location_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/image_service.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class DiaryController {
  final LocationService _locationService = const LocationService();
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
    double? lat;
    double? lon;
    String? placeName;

    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      lat = position.latitude;
      lon = position.longitude;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.locality, p.administrativeArea, p.country]
              .where((e) => e != null && e!.trim().isNotEmpty)
              .map((e) => e!.trim())
              .toList();
          if (parts.isNotEmpty) placeName = parts.join(', ');
        }
      } catch (_) {}
    }
    final entry = DiaryEntry(
      id: id,
      title: title,
      content: content,
      dateTime: DateTime.now(),
      mood: mood,
      imagePaths: imageFiles.map((f) => f.path).toList(),
      latitude: lat,
      longitude: lon,
      weatherSummary: null,
      placeName: placeName,
    );
    await _storageService.saveEntry(entry);
    return entry;
  }
}
