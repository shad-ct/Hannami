import '../../models/diary_entry.dart';
import '../../core/services/storage_service.dart';

class HomeController {
  final StorageService _storage = const StorageService();
  HomeController();

  Future<List<DiaryEntry>> loadEntries() async {
    return _storage.loadEntries();
  }
}
