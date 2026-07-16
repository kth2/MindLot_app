import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Light & dark themes with Noto Serif TC for a classical, engraved feel.
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scaffold: AppColors.paper,
        card: AppColors.paperCard,
        onSurface: AppColors.ink,
        onSurfaceSoft: AppColors.inkSoft,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scaffold: AppColors.lacquerNight,
        card: AppColors.lacquerCard,
        onSurface: AppColors.candleText,
        onSurfaceSoft: AppColors.candleTextSoft,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color card,
    required Color onSurface,
    required Color onSurfaceSoft,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.vermilion,
      brightness: brightness,
      primary: AppColors.vermilion,
      secondary: AppColors.gold,
      surface: scaffold,
      onSurface: onSurface,
    );

    final serif = GoogleFonts.notoSerifTcTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: serif,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: serif.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.vermilion,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: serif.titleMedium?.copyWith(letterSpacing: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vermilion,
          side: const BorderSide(color: AppColors.vermilion),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: serif.titleMedium?.copyWith(letterSpacing: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.vermilion.withValues(alpha: 0.15),
        labelStyle: serif.bodyMedium,
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.gold.withValues(alpha: 0.3),
        thickness: 0.8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onSurface,
        contentTextStyle: serif.bodyMedium?.copyWith(color: scaffold),
      ),
    );
  }
}
