import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../models/diary_entry.dart';
import '../../core/utils/date_utils.dart';
import 'mood.dart';
import 'mood_animated.dart';
import '../../core/services/storage_service.dart';
import 'diary_editor_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry? entry;
  const DiaryDetailScreen({super.key, this.entry});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  DiaryEntry? _entry;
  final StorageService _storage = const StorageService();

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _edit() async {
    final e = _entry;
    if (e == null) return;
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => DiaryEditorScreen(entry: e)),
    );
    if (!mounted) return;
    if (result is DiaryEntry) {
      setState(() => _entry = result);
    } else if (result == 'deleted') {
      if (mounted) Navigator.pop(context, 'deleted');
    }
  }

  Future<void> _delete() async {
    final e = _entry;
    if (e == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Delete this entry permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _storage.deleteEntry(e.id);
    if (mounted) Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    final e = _entry;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diary Detail')),
        body: const Center(child: Text('Entry not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(e.title),
        actions: [
          IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), tooltip: 'Delete', onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (e.imagePaths.isNotEmpty) ...[
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final path = e.imagePaths[i];
                  return GestureDetector(
                    onTap: () => _showImage(context, path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(path),
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: e.imagePaths.length,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(e.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: moodByKey(e.mood).description,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoodEmojiAnimated(emoji: moodByKey(e.mood).emoji, animate: true, size: 24),
                    const SizedBox(width: 6),
                    Text(moodByKey(e.mood).name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _iconText(Icons.calendar_month, DateUtilsExt.friendly(e.dateTime)),
              const SizedBox(width: 20),
              if (e.tags.isNotEmpty)
                Expanded(
                  child: _iconText(Icons.label, e.tags.join(', ')),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(e.content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  void _showImage(BuildContext context, String path) {
    final storage = const StorageService();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(path.split('/').last, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final exported = await storage.exportImage(File(path));
                    if (exported != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved copy to exports/${exported.path.split('/').last}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Share.shareXFiles([XFile(path)]);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
