import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../models/diary_entry.dart';
import '../../core/utils/date_utils.dart';
import '../../core/services/storage_service.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry? entry;
  const DiaryDetailScreen({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final e = entry;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diary Detail')),
        body: const Center(child: Text('Entry not found')),
        bottomNavigationBar: HannamiBottomNav(currentRoute: routeName),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Images preview section
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _iconText(Icons.calendar_month, DateUtilsExt.friendly(e.dateTime)),
              if (e.placeName != null && e.placeName!.isNotEmpty)
                _iconText(Icons.place, e.placeName!),
              if (e.tags.isNotEmpty)
                _iconText(Icons.label, e.tags.join(', ')),
            ],
          ),
          const SizedBox(height: 16),
          Text(e.content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      bottomNavigationBar: HannamiBottomNav(currentRoute: routeName),
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
