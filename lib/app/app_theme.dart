import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';
import '../core/fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData themed({
    required Color accent,
    required Brightness brightness,
    required String preferredFont,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    final fontFamily = HannamiFonts.familyFor(preferredFont);
    final baseTextTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
    ).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.background,
      cardColor: isDark ? HannamiColors.cardBackground : scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: HannamiTextStyles.titleMedium.copyWith(
          color: scheme.onBackground,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(color: scheme.onBackground),
      ),
      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge,
        displayMedium: baseTextTheme.displayMedium,
        displaySmall: baseTextTheme.displaySmall,
        headlineLarge: baseTextTheme.headlineLarge,
        headlineMedium: baseTextTheme.headlineMedium,
        headlineSmall: baseTextTheme.headlineSmall,
        titleLarge: baseTextTheme.titleLarge,
        titleMedium: HannamiTextStyles.titleMedium.copyWith(
          color: scheme.onBackground,
          fontFamily: fontFamily,
        ),
        titleSmall: baseTextTheme.titleSmall,
        bodyLarge: baseTextTheme.bodyLarge,
        bodyMedium: HannamiTextStyles.bodyMedium.copyWith(
          color: scheme.onBackground.withOpacity(0.9),
          fontFamily: fontFamily,
        ),
        bodySmall: baseTextTheme.bodySmall,
        labelLarge: baseTextTheme.labelLarge,
        labelMedium: baseTextTheme.labelMedium,
        labelSmall: baseTextTheme.labelSmall,
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
