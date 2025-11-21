import '../../models/diary_entry.dart';
import '../../core/services/storage_service.dart';

class CalendarController {
  final StorageService _storage = const StorageService();
  CalendarController();

  Future<List<DiaryEntry>> loadAll() => _storage.loadEntries();

  Map<DateTime, List<DiaryEntry>> groupByDate(List<DiaryEntry> entries) {
    final map = <DateTime, List<DiaryEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    return map;
  }
}
