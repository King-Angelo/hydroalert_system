import 'package:flutter/material.dart';

abstract final class AdminColors {
  static const background = Color(0xFF0A1118);
  static const surface = Color(0xFF111B24);
  static const surfaceAlt = Color(0xFF172432);
  static const border = Color(0xFF22384A);
  static const primary = Color(0xFF10B3A3);
  static const warning = Color(0xFFF5B14A);
  static const danger = Color(0xFFE45757);
  static const textPrimary = Color(0xFFE6EEF5);
  static const textMuted = Color(0xFF9FB4C4);
}

ThemeData buildAdminDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AdminColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    surface: AdminColors.surface,
    primary: AdminColors.primary,
    secondary: AdminColors.warning,
    error: AdminColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AdminColors.background,
    cardTheme: CardThemeData(
      color: AdminColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AdminColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.2),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AdminColors.textPrimary),
      titleMedium: TextStyle(color: AdminColors.textPrimary),
      titleLarge: TextStyle(
        color: AdminColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}