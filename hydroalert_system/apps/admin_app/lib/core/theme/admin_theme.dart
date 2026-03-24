import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyberpunk-inspired admin palette (neon on deep void). Used across admin UI only.
abstract final class AdminColors {
  static const background = Color(0xFF05030A);
  static const backgroundMid = Color(0xFF0A0618);
  static const surface = Color(0xFF0E081C);
  static const surfaceAlt = Color(0xFF160F2A);
  static const border = Color(0xFF2D2450);
  /// Electric cyan — primary actions, links, OK states.
  static const primary = Color(0xFF00E5FF);
  /// Hot magenta — secondary emphasis, accents.
  static const accent = Color(0xFFFF2A8C);
  static const warning = Color(0xFFFFEA00);
  static const danger = Color(0xFFFF0D5A);
  static const textPrimary = Color(0xFFE8F8FC);
  static const textMuted = Color(0xFF7A8FA0);
}

abstract final class AdminCyberDecor {
  static List<BoxShadow> neonGlow(Color c, {double blur = 18}) => [
        BoxShadow(
          color: c.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ];

  static BoxDecoration loginCardFrame() => BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          ...neonGlow(AdminColors.primary, blur: 28),
          BoxShadow(
            color: AdminColors.accent.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: -4,
          ),
        ],
      );
}

ThemeData buildAdminDarkTheme() {
  final baseDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AdminColors.background,
  );

  final textTheme = GoogleFonts.exo2TextTheme(baseDark.textTheme).apply(
    bodyColor: AdminColors.textPrimary,
    displayColor: AdminColors.textPrimary,
  );

  final cyberTitles = textTheme.copyWith(
    headlineSmall: GoogleFonts.orbitron(
      textStyle: textTheme.headlineSmall,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    ),
    titleLarge: GoogleFonts.orbitron(
      textStyle: textTheme.titleLarge,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    titleMedium: GoogleFonts.orbitron(
      textStyle: textTheme.titleMedium,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    ),
    titleSmall: GoogleFonts.orbitron(
      textStyle: textTheme.titleSmall,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  final scheme = const ColorScheme.dark(
    surface: AdminColors.surface,
    primary: AdminColors.primary,
    onPrimary: Color(0xFF05030A),
    secondary: AdminColors.accent,
    onSecondary: Color(0xFF05030A),
    tertiary: AdminColors.accent,
    error: AdminColors.danger,
    onError: Color(0xFFFFFFFF),
    onSurface: AdminColors.textPrimary,
    outline: AdminColors.border,
    surfaceContainerHighest: AdminColors.surfaceAlt,
  );

  return baseDark.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AdminColors.background,
    textTheme: cyberTitles,
    primaryColor: AdminColors.primary,
    dividerTheme: DividerThemeData(
      color: AdminColors.border.withValues(alpha: 0.55),
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AdminColors.primary,
      circularTrackColor: AdminColors.surfaceAlt,
    ),
    cardTheme: CardThemeData(
      color: AdminColors.surface,
      elevation: 0,
      shadowColor: AdminColors.primary.withValues(alpha: 0.2),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AdminColors.primary.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminColors.surfaceAlt,
      labelStyle: TextStyle(
        color: AdminColors.textMuted,
        letterSpacing: 0.3,
      ),
      hintStyle: TextStyle(
        color: AdminColors.textMuted.withValues(alpha: 0.75),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AdminColors.border.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AdminColors.border.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminColors.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: const Color(0xFF05030A),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          fontSize: 13,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.primary,
        side: BorderSide(color: AdminColors.primary.withValues(alpha: 0.65)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AdminColors.accent,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AdminColors.textMuted,
      textColor: AdminColors.textPrimary,
      selectedColor: AdminColors.primary,
      selectedTileColor: AdminColors.surfaceAlt,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AdminColors.surfaceAlt,
      selectedColor: AdminColors.primary.withValues(alpha: 0.18),
      disabledColor: AdminColors.surfaceAlt,
      labelStyle: const TextStyle(color: AdminColors.textPrimary, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: AdminColors.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      side: BorderSide(color: AdminColors.border.withValues(alpha: 0.85)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AdminColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AdminColors.primary.withValues(alpha: 0.25)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AdminColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AdminColors.primary.withValues(alpha: 0.35)),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AdminColors.surfaceAlt,
        filled: true,
      ),
    ),
    iconTheme: const IconThemeData(color: AdminColors.textMuted),
  );
}
