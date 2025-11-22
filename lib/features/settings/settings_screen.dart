import 'package:flutter/material.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/swipe_nav.dart';
import '../../core/fonts.dart';
import 'settings_controller.dart';
import '../../models/user_settings.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool enableSwipeNav;
  const SettingsScreen({
    super.key,
    this.showBottomNav = true,
    this.enableSwipeNav = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = SettingsController();
  UserSettings? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await _controller.load();
    if (!mounted) return;
    setState(() {
      _settings = loaded;
      _loading = false;
    });
  }

  Future<void> _applySetting(
    UserSettings Function(UserSettings current) mutate,
  ) async {
    final current = _settings;
    if (current == null) return;
    final updated = mutate(current);
    if (!mounted) return;
    setState(() => _settings = updated);
    await _controller.update(updated);
  }

  Future<void> _pickFont() async {
    final current = _settings;
    if (current == null) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FontPickerSheet(current: current.preferredFont),
    );
    if (!mounted || selected == null || selected == current.preferredFont) {
      return;
    }
    await _applySetting((_) => current.copyWith(preferredFont: selected));
  }

  Future<void> _exportCsv() async {
    final file = await _controller.exportCsv();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          file == null ? 'No entries to export.' : 'Exported to ${file.path}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final content = Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Builder(
        builder: (context) {
          if (_loading || _settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = _settings!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const _SectionHeader('Diary Settings'),
              ListTile(
                title: const Text('Data Folder'),
                subtitle: Text(
                  s.dataFolderPath == null || s.dataFolderPath!.isEmpty
                      ? 'Not selected'
                      : s.dataFolderPath!,
                ),
                trailing: const Icon(Icons.folder_open),
                onTap: () async {
                  if (Platform.isAndroid) {
                    await [
                      Permission.storage,
                      Permission.manageExternalStorage,
                    ].request();
                  }
                  final path = await getDirectoryPath(
                    confirmButtonText: 'Use This Folder',
                  );
                  if (!mounted || path == null || path.isEmpty) return;
                  await _applySetting(
                    (current) => current.copyWith(dataFolderPath: path),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Backup Enabled'),
                value: s.backupEnabled,
                onChanged: (v) => _applySetting(
                  (current) => current.copyWith(backupEnabled: v),
                ),
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
                            onTap: () =>
                                Navigator.pop(context, ThemeMode.system),
                          ),
                          ListTile(
                            leading: const Icon(Icons.light_mode),
                            title: const Text('Light'),
                            onTap: () =>
                                Navigator.pop(context, ThemeMode.light),
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
                  if (!mounted || choice == null) return;
                  await _applySetting(
                    (current) => current.copyWith(themeMode: choice),
                  );
                },
              ),
              ListTile(
                title: const Text('Font Style'),
                subtitle: Text(
                  HannamiFonts.resolve(s.preferredFont).preview,
                  style: HannamiFonts.previewStyle(s.preferredFont, size: 14),
                ),
                trailing: Text(
                  s.preferredFont,
                  style: HannamiFonts.previewStyle(s.preferredFont, size: 16),
                ),
                onTap: _pickFont,
              ),
              const SizedBox(height: 8),
              const Text('Accent Color'),
              const SizedBox(height: 8),
              _ColorPalette(
                selected: s.accentColor,
                onSelected: (c) => _applySetting(
                  (current) => current.copyWith(accentColor: c),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav
          ? HannamiBottomNav(currentRoute: routeName)
          : null,
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
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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
      children: _colors.map((color) {
        final isSelected = color == selected;
        final borderColor = isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.black26;
        return GestureDetector(
          onTap: () => onSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isSelected ? 42 : 36,
            height: isSelected ? 42 : 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 20, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _FontPickerSheet extends StatelessWidget {
  final String current;
  const _FontPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: HannamiFonts.options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = HannamiFonts.options[index];
          final selected = option.name == current;
          return ListTile(
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              option.name,
              style: TextStyle(
                fontFamily: option.family,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              option.preview,
              style: TextStyle(fontFamily: option.family, fontSize: 14),
            ),
            onTap: () => Navigator.pop(context, option.name),
          );
        },
      ),
    );
  }
}
