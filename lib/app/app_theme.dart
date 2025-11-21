import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData themed({
    required Color accent,
    required Brightness brightness,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.background,
      cardColor: isDark ? HannamiColors.cardBackground : scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: HannamiTextStyles.titleMedium.copyWith(color: scheme.onBackground),
        iconTheme: IconThemeData(color: scheme.onBackground),
      ),
      textTheme: TextTheme(
        titleMedium: HannamiTextStyles.titleMedium.copyWith(color: scheme.onBackground),
        bodyMedium: HannamiTextStyles.bodyMedium.copyWith(color: scheme.onBackground.withOpacity(0.9)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.background,
        elevation: 0,
        indicatorColor: scheme.surfaceContainerHighest,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
        ),
      ),
    );
  }
}
