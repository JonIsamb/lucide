import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the single (light) theme of the app.
///
/// Centralising styles here keeps widgets short: they ask the theme for
/// "titleLarge" instead of repeating font sizes and colors.
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondaryContainer: AppColors.sand,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
      error: AppColors.fall,
    );

    const textTheme = TextTheme(
      // Screen titles, e.g. "Catalogue".
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
      // Row titles (asset name).
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.ink),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
      // Row subtitles and secondary labels.
      bodySmall: TextStyle(fontSize: 13, color: AppColors.muted),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
