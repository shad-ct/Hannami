import 'package:flutter/material.dart';

class HannamiFontOption {
  final String name; // persisted label in settings
  final String? family; // actual font family registered in pubspec
  final String preview; // sample text shown in UI
  const HannamiFontOption({
    required this.name,
    required this.family,
    required this.preview,
  });
}

class HannamiFonts {
  HannamiFonts._();

  static const List<HannamiFontOption> options = [
    HannamiFontOption(
      name: 'Default',
      family: null,
      preview: 'System default typeface',
    ),
    HannamiFontOption(
      name: 'Playfair Display',
      family: 'Playfair Display',
      preview: 'Elegant serif storytelling',
    ),
    HannamiFontOption(
      name: 'Saira',
      family: 'Saira',
      preview: 'Clean modern sans for everyday use',
    ),
    HannamiFontOption(
      name: 'Source Code Pro',
      family: 'Source Code Pro',
      preview: 'Developer friendly monospace look',
    ),
    HannamiFontOption(
      name: 'Dancing Script',
      family: 'Dancing Script',
      preview: 'Playful handwritten rhythm',
    ),
    HannamiFontOption(
      name: 'Pacifico',
      family: 'Pacifico',
      preview: 'Casual brush signature style',
    ),
  ];

  static HannamiFontOption resolve(String name) {
    return options.firstWhere(
      (o) => o.name == name,
      orElse: () => options.first,
    );
  }

  static String? familyFor(String name) => resolve(name).family;

  static TextStyle previewStyle(String name, {double size = 18}) {
    final option = resolve(name);
    return TextStyle(fontFamily: option.family, fontSize: size);
  }
}
