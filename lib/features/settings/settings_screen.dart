import 'package:flutter/material.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/swipe_nav.dart';
import 'settings_controller.dart';
import '../../models/user_settings.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool enableSwipeNav;
  const SettingsScreen({super.key, this.showBottomNav = true, this.enableSwipeNav = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = SettingsController();
  late Future<UserSettings> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.load();
  }

  Future<void> _exportCsv() async {
    final file = await _controller.exportCsv();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(file == null ? 'No entries to export.' : 'Exported to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final content = Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<UserSettings>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snapshot.data ?? const UserSettings();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const _SectionHeader('Diary Settings'),
              ListTile(
                title: const Text('Data Folder'),
                subtitle: Text(s.dataFolderPath == null || s.dataFolderPath!.isEmpty ? 'Not selected' : s.dataFolderPath!),
                trailing: const Icon(Icons.folder_open),
                onTap: () async {
                  if (Platform.isAndroid) {
                    await [Permission.storage, Permission.manageExternalStorage].request();
                  }
                  final path = await getDirectoryPath(confirmButtonText: 'Use This Folder');
                  if (path != null && path.isNotEmpty) {
                    final updated = s.copyWith(dataFolderPath: path);
                    await _controller.update(updated);
                    if (mounted) setState(() => _future = Future.value(updated));
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Backup Enabled'),
                value: s.backupEnabled,
                onChanged: (v) async {
                  final updated = s.copyWith(backupEnabled: v);
                  await _controller.update(updated);
                  if (mounted) setState(() => _future = Future.value(updated));
                },
              ),
              ListTile(
                title: const Text('Export Entries (CSV)'),
                trailing: const Icon(Icons.download),
                onTap: _exportCsv,
              ),
              const SizedBox(height: 16),
              const _SectionHeader('Appearance'),
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(s.themeMode.name),
                onTap: () async {
                  final choice = await showModalBottomSheet<ThemeMode>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.brightness_auto),
                            title: const Text('System'),
                            onTap: () => Navigator.pop(context, ThemeMode.system),
                          ),
                          ListTile(
                            leading: const Icon(Icons.light_mode),
                            title: const Text('Light'),
                            onTap: () => Navigator.pop(context, ThemeMode.light),
                          ),
                          ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: const Text('Dark'),
                            onTap: () => Navigator.pop(context, ThemeMode.dark),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (choice != null) {
                    final updated = s.copyWith(themeMode: choice);
                    await _controller.update(updated);
                    if (mounted) setState(() => _future = Future.value(updated));
                  }
                },
              ),
              ListTile(
                title: const Text('Font Style'),
                subtitle: Text(s.preferredFont),
                onTap: () async {
                  final updated = s.copyWith(preferredFont: s.preferredFont == 'Default' ? 'Serif' : 'Default');
                  await _controller.update(updated);
                  if (mounted) setState(() => _future = Future.value(updated));
                },
              ),
              const SizedBox(height: 8),
              const Text('Accent Color'),
              const SizedBox(height: 8),
              _ColorPalette(
                selected: s.accentColor,
                onSelected: (c) async {
                  final updated = s.copyWith(accentColor: c);
                  await _controller.update(updated);
                  if (mounted) setState(() => _future = Future.value(updated));
                },
              ),
            ],
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelected;
  const _ColorPalette({required this.selected, required this.onSelected});

  static const List<Color> _colors = [
    Color(0xFF6750A4), // purple
    Color(0xFF386641), // green
    Color(0xFF0B7285), // teal
    Color(0xFF1565C0), // blue
    Color(0xFF2E7D32), // green
    Color(0xFFD81B60), // pink
    Color(0xFFEF6C00), // orange
    Color(0xFF00897B), // aqua
    Color(0xFF5E8FFF), // original secondary
    Color(0xFF70A6FF), // original primary
    Color(0xFF8E24AA), // deep purple
    Color(0xFF26A69A), // teal
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((c) {
        final isSelected = c.value == selected.value;
        return GestureDetector(
          onTap: () => onSelected(c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.black26,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}
