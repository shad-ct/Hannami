import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/swipe_nav.dart';
import 'media_controller.dart';
import 'dart:io';

class MediaScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool enableSwipeNav;
  const MediaScreen({super.key, this.showBottomNav = true, this.enableSwipeNav = true});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final _controller = MediaController();
  late Future<List<File>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.loadImages();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _controller.loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final content = Scaffold(
      appBar: AppBar(title: const Text('Media'), actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))]),
      body: FutureBuilder<List<File>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data ?? const [];
          if (files.isEmpty) {
            return const Center(child: Text('No images yet'));
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: files.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _showPreview(files[i]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(files[i], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav ? HannamiBottomNav(currentRoute: routeName) : null,
    );
    if (widget.enableSwipeNav) {
      return SwipeNav(currentRoute: routeName, child: content);
    }
    return content;
  }

  Future<void> _showPreview(File file) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final exported = await _controller.exportImage(file);
                      if (exported != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved copy to ${exported.path.split('/').last}')),
                        );
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Share.shareXFiles([XFile(file.path)]);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final entry = await _controller.entryForImage(file.path);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      if (entry != null) {
                        Navigator.pushNamed(context, '/diary-detail', arguments: entry);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Related entry not found')));
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Entry'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

