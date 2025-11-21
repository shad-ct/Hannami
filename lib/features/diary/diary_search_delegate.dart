import 'package:flutter/material.dart';
import '../../models/diary_entry.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/date_utils.dart';

class DiarySearchDelegate extends SearchDelegate<DiaryEntry?> {
  final StorageService _storage = const StorageService();
  List<DiaryEntry>? _cache;
  DiarySearchDelegate();

  Future<List<DiaryEntry>> _load() async {
    _cache ??= await _storage.loadEntries();
    return _cache!;
  }

  @override
  String get searchFieldLabel => 'Search diary entries';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  Iterable<DiaryEntry> _filter(List<DiaryEntry> entries) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries.take(10);
    return entries.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.content.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = _filter(snapshot.data ?? const []).toList();
        if (list.isEmpty) {
          return const Center(child: Text('No matches'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (c, i) {
            final e = list[i];
            return ListTile(
              title: Text(e.title),
              subtitle: Text(
                '${DateUtilsExt.friendly(e.dateTime)}\n${e.content}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => close(context, e),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemCount: list.length,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = _filter(snapshot.data ?? const []).toList();
        if (list.isEmpty) {
          return const Center(child: Text('Type to search entries'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (c, i) {
            final e = list[i];
            return ListTile(
              title: Text(e.title),
              subtitle: Text(DateUtilsExt.friendly(e.dateTime)),
              onTap: () => close(context, e),
            );
          },
        );
      },
    );
  }
}
