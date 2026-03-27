import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Administrative UI palette and decor aligned with `design-spec.md`
/// (operational dark theme: status green / amber / red on slate surfaces).
abstract final class AdminColors {
  /// Page background — spec `--background`
  static const background = Color(0xFF0F1218);
  /// Gradient / mid layer (between background and cards)
  static const backgroundMid = Color(0xFF121923);
  /// Card surfaces — spec `--card`
  static const surface = Color(0xFF151A22);
  /// Muted panels — spec `--muted`
  static const surfaceAlt = Color(0xFF1E232C);
  /// Borders — spec `--border`
  static const border = Color(0xFF272D38);
  /// Safe / online / brand accent — spec `--primary`, `--status-normal`
  static const primary = Color(0xFF1FBA4F);
  /// Watch / pending / secondary emphasis — spec `--status-alert`
  static const accent = Color(0xFFF0A422);
  static const warning = Color(0xFFF0A422);
  /// Critical / error — spec `--status-critical`
  static const danger = Color(0xFFE23636);
  static const textPrimary = Color(0xFFE8EAEE);
  /// Secondary text — spec `--muted-foreground`
  static const textMuted = Color(0xFF718096);
}

abstract final class AdminCyberDecor {
  /// Spec-style glow: status color at ~40% opacity.
  static List<BoxShadow> statusGlow(Color c, {double blur = 12}) => [
        BoxShadow(
          color: c.withValues(alpha: 0.45),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ];

  static BoxDecoration loginCardFrame() => BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          ...statusGlow(AdminColors.primary, blur: 24),
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.12),
            blurRadius: 36,
            spreadRadius: -2,
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

  final textTheme = GoogleFonts.interTextTheme(baseDark.textTheme).apply(
    bodyColor: AdminColors.textPrimary,
    displayColor: AdminColors.textPrimary,
  );

  final titles = textTheme.copyWith(
    headlineSmall: GoogleFonts.inter(
      textStyle: textTheme.headlineSmall,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleLarge: GoogleFonts.inter(
      textStyle: textTheme.titleLarge,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.15,
    ),
    titleMedium: GoogleFonts.inter(
      textStyle: textTheme.titleMedium,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    titleSmall: GoogleFonts.inter(
      textStyle: textTheme.titleSmall,
      color: AdminColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
  );

  const scheme = ColorScheme.dark(
    surface: AdminColors.surface,
    primary: AdminColors.primary,
    onPrimary: AdminColors.background,
    secondary: AdminColors.accent,
    onSecondary: AdminColors.background,
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
    textTheme: titles,
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
      shadowColor: Colors.black.withValues(alpha: 0.35),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AdminColors.border,
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminColors.surfaceAlt,
      labelStyle: TextStyle(
        color: AdminColors.textMuted,
        letterSpacing: 0.2,
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
        foregroundColor: AdminColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          fontSize: 14,
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
      selectedColor: AdminColors.primary.withValues(alpha: 0.15),
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
        side: BorderSide(color: AdminColors.border.withValues(alpha: 0.9)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AdminColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AdminColors.border.withValues(alpha: 0.95)),
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
