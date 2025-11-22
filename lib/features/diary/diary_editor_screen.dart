import 'dart:io';
import 'package:flutter/material.dart';
import 'diary_controller.dart';
import 'mood.dart';
import 'mood_animated.dart';
import '../../models/diary_entry.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? entry;
  const DiaryEditorScreen({super.key, this.entry});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _controller = DiaryController();

  List<File> _images = [];
  bool _saving = false;
  String? _weatherSummary;
  double? _lat;
  double? _lon;
  String _selectedMood = 'neutral';

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _titleController.text = e.title;
      _bodyController.text = e.content;
      _selectedMood = e.mood;
      _weatherSummary = e.weatherSummary;
      _lat = e.latitude;
      _lon = e.longitude;
      // Store existing image references as File instances so the UI can show previews.
      _images = e.imagePaths.map((p) => File(p)).toList();
    }
  }

  Future<void> _pickImages() async {
    final files = await _controller.pickImagesAndStoreTemp();
    if (files.isEmpty) return;
    final existingPaths = _images.map((f) => f.path).toSet();
    final unique = files.where((f) => !existingPaths.contains(f.path)).toList();
    if (unique.isEmpty) return;
    setState(() {
      _images.addAll(unique);
    });
  }

  bool get _isEditing => widget.entry != null;

  void _removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final existing = widget.entry!;
        final trimmedTitle = _titleController.text.trim();
        final updated = await _controller.updateAndPersist(
          existing,
          title: trimmedTitle.isEmpty ? existing.title : trimmedTitle,
          content: _bodyController.text.trim(),
          mood: _selectedMood,
          imagePaths: _images.map((f) => f.path).toList(),
        );
        if (!mounted) return;
        Navigator.pop(context, updated);
      } else {
        final entry = await _controller.createAndPersist(
          title: _titleController.text.trim(),
          content: _bodyController.text.trim(),
          mood: _selectedMood,
          imageFiles: _images,
        );
        if (!mounted) return;
        Navigator.pop(context, entry);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      } else {
        _saving = false;
      }
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this diary entry? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _controller.deleteEntry(widget.entry!.id);
    if (mounted) Navigator.pop(context, 'deleted');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Diary Entry' : 'New Diary Entry'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Entry',
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Mood', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  for (final mood in diaryMoods)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Tooltip(
                        message: mood.description,
                        preferBelow: false,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedMood == mood.key
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMood == mood.key
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                width: 1.6,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MoodEmojiAnimated(
                                  emoji: mood.emoji,
                                  animate: _selectedMood == mood.key,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedMood == mood.key
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
              ),
              const SizedBox(width: 12),
              if (_images.isNotEmpty)
                Text(
                  '${_images.length} selected',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_images.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final file = _images[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 96,
                            height: 96,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              size: 24,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Tooltip(
                          message: 'Remove image',
                          child: GestureDetector(
                            onTap: () => _removeImageAt(i),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _images.length,
              ),
            ),
          const SizedBox(height: 16),
          if (_weatherSummary != null)
            Text(
              'Weather: $_weatherSummary (${_lat?.toStringAsFixed(4)}, ${_lon?.toStringAsFixed(4)})',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              _saving
                  ? (_isEditing ? 'Updating...' : 'Saving...')
                  : (_isEditing ? 'Save Changes' : 'Save Entry'),
            ),
          ),
        ],
      ),
    );
  }
}
