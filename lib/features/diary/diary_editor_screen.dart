import 'dart:io';
import 'package:flutter/material.dart';
import 'diary_controller.dart';
import 'mood.dart';
import 'mood_animated.dart';

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key});

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

  Future<void> _pickImages() async {
    final files = await _controller.pickImagesAndStoreTemp();
    setState(() {
      _images.addAll(files);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final entry = await _controller.createAndPersist(
      title: _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim(),
      content: _bodyController.text.trim(),
      mood: _selectedMood,
      imageFiles: _images,
    );
    _weatherSummary = entry.weatherSummary;
    _lat = entry.latitude;
    _lon = entry.longitude;
    if (mounted) {
      Navigator.pop(context, entry);
    }
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
      appBar: AppBar(title: const Text('New Diary Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(labelText: 'Content', alignLabelWithHint: true, border: OutlineInputBorder()),
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedMood == mood.key ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMood == mood.key ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                width: 1.6,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MoodEmojiAnimated(emoji: mood.emoji, animate: _selectedMood == mood.key, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  mood.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedMood == mood.key
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
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
                Text('${_images.length} selected', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (_images.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_images[i], width: 96, height: 96, fit: BoxFit.cover),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _images.length,
              ),
            ),
          const SizedBox(height: 16),
          if (_weatherSummary != null)
            Text('Weather: $_weatherSummary (${_lat?.toStringAsFixed(4)}, ${_lon?.toStringAsFixed(4)})', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width:16,height:16,child: CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Entry'),
          ),
        ],
      ),
    );
  }
}
